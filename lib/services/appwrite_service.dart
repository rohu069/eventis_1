import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
    ..setProject('67aa277600042d235f09'); // Replace with your Appwrite project ID

  static final Account account = Account(client);
  static final Databases databases = Databases(client);
  static final Storage storage = Storage(client); // Storage service

  // **1️⃣ Sign Up Method**
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
      );

      await databases.createDocument(
        databaseId: '67aa2889002cd582ca1c',
        collectionId: '67aa28a80008eb0d3bda',
        documentId: user.$id,
        data: {
          'name': name,
          'studentId': studentId,
          'phone': phone,
          'email': email,
          'userId': user.$id,
        },
      );

      return null; // Success
    } catch (e) {
      print('SignUp Error: $e');
      return e.toString(); // Return error
    }
  }

  // **2️⃣ Login Method**
  static Future<String?> login({required String email, required String password}) async {
    try {
      await account.createEmailPasswordSession(email: email, password: password);

      // Verify session creation
      models.User user = await account.get();
      print("✅ Login Successful: ${user.$id}");

      return null; // Success
    } on AppwriteException catch (e) {
      print('Login Error: ${e.message}');
      return e.message;
    } catch (e) {
      print('Unexpected Login Error: $e');
      return e.toString();
    }
  }

  // **3️⃣ Logout Method**
  static Future<void> logout() async {
    try {
      await account.deleteSessions();
      print("✅ User successfully logged out.");
    } on AppwriteException catch (e) {
      print('Logout Error: ${e.message}');
    } catch (e) {
      print('Unexpected Logout Error: $e');
    }
  }

  // **4️⃣ Upload Image to Appwrite Storage (Store File ID, Not URL)**
  static Future<String?> uploadEventImage(File imageFile) async {
    try {
      final response = await storage.createFile(
        bucketId: '67b78e8a000a2b7b43fd', // Your bucket ID
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imageFile.path),
      );

      return response.$id; // Store file ID
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // **5️⃣ Register Event (Store File ID Instead of URL)**
  static Future<String?> registerEvent({
    required String name,
    required String batch,
    required String department,
    required String category,
    required String eventName,
    required String eventPurpose,
    required String eventDate,
    required String eventVenue,
    required File? eventImage, // Image file
  }) async {
    try {
      String? userId = await getCurrentUserId();
      if (userId == null) {
        return 'User not logged in';
      }

      // Upload image if provided
      String? fileId;
      if (eventImage != null) {
        fileId = await uploadEventImage(eventImage);
        if (fileId == null) return 'Image upload failed';
      }

      await databases.createDocument(
        databaseId: '67aa2889002cd582ca1c', // Your database ID
        collectionId: '67b78ecb001e8c2ac03d', // Your collection ID
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
          'event_image_id': fileId, // Store file ID instead of full URL
          'is_verified': false, // Add verification flag (default: false)
        },
      );

      return null; // Success
    } catch (e) {
      print('Register Event Error: $e');
      return e.toString(); // Return error
    }
  }

  // **6️⃣ Get Event Registrations for Admin Dashboard**
// **8️⃣ Fetch Event Registrations for Admin Dashboard**
static Future<List<Map<String, dynamic>>> getEventRegistrations() async {
  try {
    final response = await databases.listDocuments(
      databaseId: '67aa2889002cd582ca1c', // Your database ID
      collectionId: '67b78ecb001e8c2ac03d', // Your event registrations collection ID
    );

    return response.documents.map((doc) => doc.data).toList();
  } catch (e) {
    print('Error fetching event registrations: $e');
    return [];
  }
}

  // **7️⃣ Verify Event Registration (Admin)**
  static Future<bool> verifyEvent(String documentId) async {
    try {
      await databases.updateDocument(
        databaseId: '67aa2889002cd582ca1c',
        collectionId: '67b78ecb001e8c2ac03d',
        documentId: documentId,
        data: {'is_verified': true}, // Mark event as verified
      );

      print('✅ Event verified successfully.');
      return true;
    } catch (e) {
      print('Error verifying event: $e');
      return false;
    }
  }

  // **8️⃣ Get Current User ID**
  static Future<String?> getCurrentUserId() async {
    try {
      models.User user = await account.get();
      return user.$id;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // **9️⃣ Get Image URL from File ID**
  static String getImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/67b78e8a000a2b7b43fd/files/$fileId/view?project=67aa277600042d235f09';
  }
}
