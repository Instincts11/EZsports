import 'package:ezsports/features/students/data/models/batch_model.dart';
import 'package:ezsports/features/students/data/models/student_model.dart';
import 'package:ezsports/features/students/data/students_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentsRepositoryProvider = Provider<StudentsRepository>((Ref ref) {
  return StudentsRepository();
});

final demoBatchesProvider = Provider<List<BatchModel>>((Ref ref) {
  return const <BatchModel>[
    BatchModel(
      batchId: 1,
      name: 'Summer Camp',
      days: 'Tue Wed Thu Fri Sat Mon',
      timeRange: '7:00 AM – 9:00 AM',
      pitch: 'Pitch A',
      studentCount: 17,
      capacity: 20,
    ),
    BatchModel(
      batchId: 2,
      name: 'Weekday Evening Batch',
      days: 'Mon Wed Fri',
      timeRange: '4:00 PM – 6:00 PM',
      pitch: 'Pitch A',
      studentCount: 4,
      capacity: 16,
    ),
    BatchModel(
      batchId: 3,
      name: 'Weekend Evening',
      days: 'Sun Sat',
      timeRange: '3:30 PM – 5:00 PM',
      pitch: 'Pitch B',
      studentCount: 15,
      capacity: 18,
    ),
    BatchModel(
      batchId: 4,
      name: 'Weekend Morning',
      days: 'Sun Sat',
      timeRange: '7:00 AM – 9:00 AM',
      pitch: 'Pitch B',
      studentCount: 107,
      capacity: 120,
    ),
  ];
});

final demoPlayersProvider = Provider<List<StudentModel>>((Ref ref) {
  return const <StudentModel>[
    StudentModel(studentId: 1, name: 'Abner Lino', initials: 'AL', parentMobile: '+91 98765 43210', feeStatus: 'due', firstName: 'Abner', lastName: 'Lino', batchName: 'Weekend Evening'),
    StudentModel(studentId: 2, name: 'Advaita S', initials: 'AS', parentMobile: '+91 98765 43210', feeStatus: 'due', firstName: 'Advaita', lastName: 'S', dob: '12 Mar 2014', gender: 'Female', emergency: '+91 99618 61588', batchName: 'Weekend Evening', attended: 6, totalSessions: 8),
    StudentModel(studentId: 3, name: 'Adwaith Renjith', initials: 'AR', parentMobile: '+91 98765 43211', feeStatus: 'due', firstName: 'Adwaith', lastName: 'Renjith', batchName: 'Weekend Evening'),
    StudentModel(studentId: 4, name: 'Druv Krishna', initials: 'DK', parentMobile: '+91 98765 43212', feeStatus: 'due', firstName: 'Druv', lastName: 'Krishna', batchName: 'Weekend Evening'),
    StudentModel(studentId: 5, name: 'Ishant Jay', initials: 'IJ', parentMobile: '+91 98765 43213', feeStatus: 'due', firstName: 'Ishant', lastName: 'Jay', batchName: 'Weekend Evening'),
    StudentModel(studentId: 6, name: 'Ivan Vineeth', initials: 'IV', parentMobile: '+91 98765 43214', feeStatus: 'due', firstName: 'Ivan', lastName: 'Vineeth', batchName: 'Weekend Evening'),
    StudentModel(studentId: 7, name: 'Jisa Jinish', initials: 'JJ', parentMobile: '+91 98765 43215', feeStatus: 'due', firstName: 'Jisa', lastName: 'Jinish', batchName: 'Weekend Evening'),
    StudentModel(studentId: 8, name: 'Johana Emil', initials: 'JE', parentMobile: '+91 98765 43216', feeStatus: 'due', firstName: 'Johana', lastName: 'Emil', batchName: 'Weekend Evening'),
    StudentModel(studentId: 9, name: 'Akhil K', initials: 'AK', parentMobile: '+91 98765 43217', feeStatus: 'paid', firstName: 'Akhil', lastName: 'K', batchName: 'Weekend Evening'),
    StudentModel(studentId: 10, name: 'Nikhil R', initials: 'NP', parentMobile: '+91 98765 43218', feeStatus: 'paid', firstName: 'Nikhil', lastName: 'R', batchName: 'Weekend Evening'),
    StudentModel(studentId: 11, name: 'Rohan S', initials: 'RS', parentMobile: '+91 98765 43219', feeStatus: 'paid', firstName: 'Rohan', lastName: 'S', batchName: 'Weekend Evening'),
    StudentModel(studentId: 12, name: 'Sachin Mathew', initials: 'SM', parentMobile: '+91 98765 43220', feeStatus: 'paid', firstName: 'Sachin', lastName: 'Mathew', batchName: 'Weekend Evening'),
    StudentModel(studentId: 13, name: 'Vishnu P', initials: 'VP', parentMobile: '+91 98765 43221', feeStatus: 'paid', firstName: 'Vishnu', lastName: 'P', batchName: 'Weekend Evening'),
    StudentModel(studentId: 14, name: 'Arjun M', initials: 'AM', parentMobile: '+91 98765 43222', feeStatus: 'paid', firstName: 'Arjun', lastName: 'M', batchName: 'Weekend Evening'),
    StudentModel(studentId: 15, name: 'Chris Babu', initials: 'CB', parentMobile: '+91 98765 43223', feeStatus: 'paid', firstName: 'Chris', lastName: 'Babu', batchName: 'Weekend Evening'),
    StudentModel(studentId: 16, name: 'Diya P', initials: 'DP', parentMobile: '+91 98470 11021', feeStatus: 'paid', firstName: 'Diya', lastName: 'P', batchName: 'Weekend Evening'),
    StudentModel(studentId: 17, name: 'Meher Ann', initials: 'MA', parentMobile: '+91 98470 11022', feeStatus: 'due', firstName: 'Meher', lastName: 'Ann', batchName: 'Weekend Morning'),
    StudentModel(studentId: 18, name: 'Nevin Jose', initials: 'NJ', parentMobile: '+91 98470 11023', feeStatus: 'paid', firstName: 'Nevin', lastName: 'Jose', batchName: 'Weekend Morning'),
    StudentModel(studentId: 19, name: 'Pooja R', initials: 'PR', parentMobile: '+91 98470 11024', feeStatus: 'paid', firstName: 'Pooja', lastName: 'R', batchName: 'Summer Camp'),
    StudentModel(studentId: 20, name: 'Rahul Dev', initials: 'RD', parentMobile: '+91 98470 11025', feeStatus: 'due', firstName: 'Rahul', lastName: 'Dev', batchName: 'Summer Camp'),
    StudentModel(studentId: 21, name: 'Sana Varghese', initials: 'SV', parentMobile: '+91 98470 11026', feeStatus: 'paid', firstName: 'Sana', lastName: 'Varghese', batchName: 'Weekday Evening Batch'),
    StudentModel(studentId: 22, name: 'Tejas Nair', initials: 'TN', parentMobile: '+91 98470 11027', feeStatus: 'paid', firstName: 'Tejas', lastName: 'Nair', batchName: 'Weekend Morning'),
    StudentModel(studentId: 23, name: 'Uma Krishnan', initials: 'UK', parentMobile: '+91 98470 11028', feeStatus: 'due', firstName: 'Uma', lastName: 'Krishnan', batchName: 'Weekend Evening'),
    StudentModel(studentId: 24, name: 'Varun Pillai', initials: 'VP', parentMobile: '+91 98470 11029', feeStatus: 'paid', firstName: 'Varun', lastName: 'Pillai', batchName: 'Weekend Morning'),
    StudentModel(studentId: 25, name: 'Zara Khan', initials: 'ZK', parentMobile: '+91 98470 11030', feeStatus: 'paid', firstName: 'Zara', lastName: 'Khan', batchName: 'Summer Camp'),
    StudentModel(studentId: 26, name: 'Anju Mary', initials: 'AM', parentMobile: '+91 98470 11031', feeStatus: 'paid', firstName: 'Anju', lastName: 'Mary', batchName: 'Weekday Evening Batch'),
    StudentModel(studentId: 27, name: 'Basil George', initials: 'BG', parentMobile: '+91 98470 11032', feeStatus: 'due', firstName: 'Basil', lastName: 'George', batchName: 'Weekend Morning'),
    StudentModel(studentId: 28, name: 'Catherine Roy', initials: 'CR', parentMobile: '+91 98470 11033', feeStatus: 'paid', firstName: 'Catherine', lastName: 'Roy', batchName: 'Weekend Evening'),
  ];
});

final playerByIdProvider = Provider.family<StudentModel?, int>((Ref ref, int id) {
  final List<StudentModel> players = ref.watch(demoPlayersProvider);
  for (final StudentModel player in players) {
    if (player.studentId == id) {
      return player;
    }
  }
  return null;
});

final batchByIdProvider = Provider.family<BatchModel?, int>((Ref ref, int id) {
  final List<BatchModel> batches = ref.watch(demoBatchesProvider);
  for (final BatchModel batch in batches) {
    if (batch.batchId == id) {
      return batch;
    }
  }
  return null;
});
