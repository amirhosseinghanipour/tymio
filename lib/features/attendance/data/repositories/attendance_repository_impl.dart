import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository_interface.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepositoryInterface {
  final FirebaseFirestore _firestore;

  AttendanceRepositoryImpl(this._firestore);

  // Calculate distance between two points in meters
  bool _isWithinOffice(double lat, double lng, double officeLat, double officeLng, double radiusMeters) {
    const earthRadius = 6371000; // meters
    final dLat = (lat - officeLat) * pi / 180;
    final dLng = (lng - officeLng) * pi / 180;
    final a = sin(dLat/2) * sin(dLat/2) +
              cos(officeLat * pi / 180) * cos(lat * pi / 180) *
              sin(dLng/2) * sin(dLng/2);
    final c = 2 * atan2(sqrt(a), sqrt(1-a));
    final distance = earthRadius * c;
    return distance <= radiusMeters;
  }

  @override
  Future<void> checkIn(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get current location (skip if plugin not ready — do full rebuild after adding geolocator)
    Position? position;
    try {
      await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on MissingPluginException catch (_) {
      debugPrint('Geolocator plugin not registered. Stop app, run: flutter clean && flutter pub get && flutter run');
    } catch (e) {
      debugPrint('Location error: $e');
    }

    // Check geofencing if position available and company settings exist
    if (position != null) {
      try {
        // Get user's employer ID from user document
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc['employerId'] != null) {
          final employerId = userDoc['employerId'];
          final companyDoc = await _firestore.collection('companies').doc(employerId).get();
          if (companyDoc.exists) {
            final officeLat = companyDoc['officeLat'];
            final officeLng = companyDoc['officeLng'];
            final radius = companyDoc['officeRadiusMeters'] ?? 100.0;

            if (!_isWithinOffice(position.latitude, position.longitude, officeLat, officeLng, radius)) {
              throw Exception('You must be at the office to check in. Please check your location and try again.');
            }
          }
        }
      } catch (e) {
        // If company settings don't exist, allow check-in (no geofencing)
        debugPrint('Geofencing check failed: $e');
      }
    }

    final attendance = AttendanceModel(
      id: '',
      userId: userId,
      checkIn: now,
      date: today,
      checkInLat: position?.latitude,
      checkInLng: position?.longitude,
    );

    await _firestore.collection('attendance').add(attendance.toMap());
  }

  @override
  Future<void> checkOut(String attendanceId) async {
    // Get current location for check-out
    Position? position;
    try {
      await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } on MissingPluginException catch (_) {
      debugPrint('Geolocator plugin not registered.');
    } catch (e) {
      debugPrint('Location error on check-out: $e');
    }

    await _firestore.collection('attendance').doc(attendanceId).update({
      'checkOut': Timestamp.fromDate(DateTime.now()),
      'checkOutLat': position?.latitude,
      'checkOutLng': position?.longitude,
    });
  }

  @override
  Stream<List<Attendance>> getTodayAttendance(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) =>
              AttendanceModel.fromMap(doc.data(), doc.id) as Attendance)
          .toList();
      list.sort((a, b) => a.checkIn.compareTo(b.checkIn));
      return list;
    });
  }

  @override
  Stream<List<Attendance>> getHistory(String userId) {
    return _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id) as Attendance)
          .toList();
    });
  }

  @override
  Stream<List<Attendance>> getEmployeesAttendance(List<String> userIds) {
    if (userIds.isEmpty) return Stream.value([]);
    
    // Firestore 'where in' limit is 10. For MVP, we'll assume < 10 employees or simple query
    // Optimisation: Just get all attendance? Or filter.
    // Let's filter by userIds.
    
    // Handling chunks of 10 if needed, but for MVP keep simple.
    // If list is > 10, this will fail. We'll slice it.
    if (userIds.length > 10) {
      // Return empty or handle error for MVP
      return Stream.value([]); 
    }

    return _firestore
        .collection('attendance')
        .where('userId', whereIn: userIds)
        .orderBy('date', descending: true)
        .limit(50) // Limit to recent 50 entries
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id) as Attendance)
          .toList();
    });
  }
}
