import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
    ..setProject('67aa277600042d235f09'); // Replace with your Appwrite project ID

  static final Account account = Account(client);
  static final Databases databases = Databases(client);
  static final Storage storage = Storage(client);

  static const String databaseId = '67aa2889002cd582ca1c';
  static const String userCollectionId = '67aa28a80008eb0d3bda';
  static const String eventCollectionId = '67b78ecb001e8c2ac03d';
  static const String bucketId = '67b78e8a000a2b7b43fd';

  /// **1️⃣ Sign Up Method**
  static Future<String?> signUp({
    required String name,
    required String studentId,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      await account.createEmailPasswordSession(email: email, password: password);

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: userCollectionId,
        documentId: user.$id,
        data: {
          'name': name,
          'studentId': studentId,
          'phone': phone,
          'email': email,
          'userId': user.$id,
        },
      );

      print("✅ User signed up and logged in.");
      return null; // Success
    } catch (e) {
      print('❌ SignUp Error: $e');
      return e.toString();
    }
  }

  /// **2️⃣ Login Method**
  static Future<String?> login({required String email, required String password}) async {
    try {
      await account.createEmailPasswordSession(email: email, password: password);
      models.User user = await account.get();
      print("✅ Login Successful: ${user.$id}");
      return null;
    } catch (e) {
      print('❌ Login Error: $e');
      return e.toString();
    }
  }

  /// **3️⃣ Logout Method**
  static Future<void> logout() async {
    try {
      await account.deleteSessions();
      print("✅ User successfully logged out.");
    } catch (e) {
      print('❌ Logout Error: $e');
    }
  }

  /// **4️⃣ Upload Image to Appwrite Storage**
  static Future<String?> uploadEventImage(File imageFile) async {
    try {
      final response = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imageFile.path),
      );

      print('✅ Uploaded Image File ID: ${response.$id}');
      return response.$id;
    } catch (e) {
      print('❌ Image Upload Error: $e');
      return null;
    }
  }

  /// **5️⃣ Register Event**
  static Future<String?> registerEvent({
    required String name,
    required String batch,
    required String department,
    required String category,
    required String eventName,
    required String eventPurpose,
    required String eventDate,
    required String eventVenue,
    required File? eventImage,
  }) async {
    try {
      String? userId = await getCurrentUserId();
      if (userId == null) {
        return 'User not logged in';
      }

      String? fileId;
      if (eventImage != null) {
        fileId = await uploadEventImage(eventImage);
        if (fileId == null) return 'Image upload failed';
      }

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'name': name,
          'batch': batch,
          'department': department,
          'category': category,
          'event_name': eventName,
          'event_purpose': eventPurpose,
          'event_date': eventDate,
          'event_venue': eventVenue,
          'event_image_id': fileId,
          'is_verified': false, // Default to false
        },
      );

      print("✅ Event Registered Successfully.");
      return null;
    } catch (e) {
      print('❌ Register Event Error: $e');
      return e.toString();
    }
  }

  /// **6️⃣ Get Event Registrations**
  static Future<List<Map<String, dynamic>>> getEventRegistrations() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId,
      );

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);

        data['image_url'] = data['event_image_id'] != null
            ? getImageUrl(data['event_image_id'])
            : null;

        return data;
      }).toList();
    } catch (e) {
      print('❌ Fetch Event Registrations Error: $e');
      return [];
    }
  }

  /// **7️⃣ Get Verified Events Only**
  static Future<List<Map<String, dynamic>>> getVerifiedEvents() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        queries: [Query.equal('is_verified', true)],
      );

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['image_url'] = data['event_image_id'] != null
            ? getImageUrl(data['event_image_id'])
            : null;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Fetch Verified Events Error: $e');
      return [];
    }
  }

  /// **8️⃣ Verify Event**
  static Future<bool> verifyEvent(String documentId) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: documentId,
        data: {'is_verified': true},
      );

      print('✅ Event verified successfully.');
      return true;
    } catch (e) {
      print('❌ Verify Event Error: $e');
      return false;
    }
  }

  /// **9️⃣ Delete an Event**
  static Future<bool> deleteEvent(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: documentId,
      );
      print('✅ Event deleted successfully.');
      return true;
    } catch (e) {
      print('❌ Delete Event Error: $e');
      return false;
    }
  }

  /// **🔟 Update Event Details**
  static Future<bool> updateEvent(String documentId, Map<String, dynamic> updatedData) async {
    try {
      await databases.updateDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: documentId,
        data: updatedData,
      );
      print('✅ Event updated successfully.');
      return true;
    } catch (e) {
      print('❌ Update Event Error: $e');
      return false;
    }
  }

  /// **🔹 Check if a Date is Today**
  static bool isToday(String date) {
    final eventDate = DateTime.parse(date);
    final today = DateTime.now();
    return eventDate.year == today.year &&
        eventDate.month == today.month &&
        eventDate.day == today.day;
  }

  /// **Get Current User ID**
  static Future<String?> getCurrentUserId() async {
    try {
      models.User user = await account.get();
      return user.$id; // User ID
    } catch (e) {
      print('❌ Error fetching current user ID: $e');
      return null;
    }
  }


    // Fetch current user details
  static Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      models.User user = await account.get();
      return {
        'id': user.$id,
        'name': user.name,
        'email': user.email,
      };
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }


  /// **🔹 Get Image URL from File ID**
  static String getImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=67aa277600042d235f09';
  }
}
