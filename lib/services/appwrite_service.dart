import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AppwriteService {
  static final Client client = Client()
    ..setEndpoint(
        'https://cloud.appwrite.io/v1') // Replace with your Appwrite endpoint
    ..setProject(
        '67aa277600042d235f09'); // Replace with your Appwrite project ID

  static final Account account = Account(client);
  static final Databases databases = Databases(client);
  static final Storage storage = Storage(client);

  static const String databaseId = '67aa2889002cd582ca1c';
  static const String userCollectionId = '67aa28a80008eb0d3bda';
  static const String eventCollectionId = '67b78ecb001e8c2ac03d';
  static const String bucketId = '67b78e8a000a2b7b43fd';
  static const String categoryId = '67cefd76002cba19fc92';
  static const String eventsId = '67e9c07d00042973758c';

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

      await account.createEmailPasswordSession(
          email: email, password: password);

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

  Future<bool> isUserLoggedIn() async {
    try {
      await AppwriteService.account.get();
      return true; // User has an active session
    } catch (e) {
      return false; // No active session
    }
  }

  static Future<String?> getUserRole() async {
    try {
      final userDetails = await getCurrentUserDetails();
      return userDetails?['role'];
    } catch (e) {
      print("❌ Error fetching user role: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: userCollectionId,
      );
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print("❌ Fetch All Users Error: $e");
      return [];
    }
  }

  /// **2️⃣ Login Method**
  static Future<String?> login(
      {required String email, required String password}) async {
    try {
      await account.createEmailPasswordSession(
          email: email, password: password);
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

  /// **5️⃣ Register Event with Additional Data**
  static Future<String?> registerEvent({
    required String name,
    required String batch,
    required String department,
    required String category,
    required String eventName,
    required String eventPurpose,
    required String eventDate,
    required String eventVenue, // New field for location
    required File? eventImage,
    required String link,
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
          'link': link,
        },
      );

      print("✅ Event Registered Successfully.");
      return null;
    } catch (e) {
      print('❌ Register Event Error: $e');
      return e.toString();
    }
  }

  /// **6️⃣ Get Event Registrations with Additional Data**
  Future<List<Map<String, dynamic>>> getEventRegistrations(
      String eventId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventsId,
        queries: [Query.equal('event_id', eventId)],
      );

      List<Map<String, dynamic>> registrations = [];

      for (var doc in response.documents) {
        Map<String, dynamic> registrationData = doc.data;
        String? userId = registrationData['user_id'];

        // 🛑 Check if user_id is null
        if (userId == null || userId.isEmpty) {
          print("⚠️ Skipping registration due to missing user_id.");
          continue;
        }

        print("🔍 Fetching user details for user_id: $userId");

        try {
          // Fetch user details from the Users Collection
          final userResponse = await databases.getDocument(
            databaseId: databaseId,
            collectionId: userCollectionId, // ✅ Ensure this is correct
            documentId: userId,
          );

          // ✅ Correct field mappings
          registrationData['name'] =
              userResponse.data["user_name"] ?? "Unknown";
          registrationData['email'] = userResponse.data["user_email"] ?? "N/A";
          registrationData['phone'] = userResponse.data["user_phone"] ?? "N/A";
        } catch (e) {
          print("❌ Error fetching user details for user_id $userId: $e");
          registrationData['name'] = "Unknown";
          registrationData['email'] = "N/A";
          registrationData['phone'] = "N/A";
        }

        registrations.add(registrationData);
      }

      print("✅ Processed Registrations with User Details: $registrations");
      return registrations;
    } catch (e) {
      print("❌ Error fetching registrations: $e");
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUnverifiedEvents() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId, // ✅ Fetch from event collection
        queries: [
          Query.equal('is_verified', false) // ✅ Only unverified events
        ],
      );

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['image_url'] = data['event_image_id'] != null
            ? getImageUrl(data['event_image_id'])
            : null;
        data['event_start_time'] = data['event_start_time'] ?? 'Not Available';
        data['event_location'] = data['event_location'] ?? 'Not Available';

        return data;
      }).toList();
    } catch (e) {
      print('❌ Fetch Unverified Events Error: $e');
      return [];
    }
  }

  /// **7️⃣ Get Verified Events with Additional Data**
  static Future<List<Map<String, dynamic>>> getVerifiedEvents(
      {String? category}) async {
    try {
      List<String> queries = [Query.equal('is_verified', true)];

      // If a category is selected, add it to the query
      if (category != null && category != 'All') {
        queries.add(Query.equal('event_category', category));
      }

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        queries: queries, // Apply category filter dynamically
      );

      // Log the response documents to see their structure
      print("🔍 Full Response: ${response.documents}");

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);

        // Debug: Log the event document to see if event_id is present
        print("🔍 Event Document: $data");

        // Handle event image
        data['image_url'] = data['event_image_id'] != null
            ? getImageUrl(data['event_image_id'])
            : null;

        // Additional data
        data['event_start_time'] = data['event_start_time'] ?? 'Not Available';
        data['event_location'] = data['event_location'] ?? 'Not Available';

        // Check if event_id is in the event data
        if (data['event_id'] != null) {
          print("🔍 Found event_id: ${data['event_id']}");
        } else {
          print("❌ Missing event_id in event document");
        }

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
  static Future<bool> deleteEvent(String eventId) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: eventId,
      );
      return true; // ✅ Return true on success
    } catch (e) {
      return false; // ❌ Return false on failure
    }
  }

  /// **🔟 Update Event Details**
  static Future<bool> updateEvent(
      String documentId, Map<String, dynamic> updatedData) async {
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
  // ✅ Get current logged-in user's ID
  static Future<String?> getCurrentUserId() async {
    try {
      models.User user = await account.get();
      return user.$id;
    } catch (e) {
      print("❌ Error getting user: $e");
      return null;
    }
  }

  // ✅ Check if user session is active
  static Future<bool> checkSession() async {
    try {
      await account.get(); // If this succeeds, the session is valid
      return true;
    } catch (e) {
      print("❌ No active session: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final document = await databases.getDocument(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        documentId: eventId,
      );

      final data = Map<String, dynamic>.from(document.data);

      // Fetch image URL if available
      data['image_url'] = data['event_image_id'] != null
          ? getImageUrl(data['event_image_id'])
          : null;

      return data;
    } catch (e) {
      print('❌ Fetch Event Details Error: $e');
      return null;
    }
  }

  /// **🔹 Register for an Event**
  static Future<bool> registerForEvent({
    required String eventId,
  }) async {
    try {
      final database = Databases(client);

      // Fetch current user details
      Map<String, dynamic>? userDetails = await getCurrentUserDetails();

      if (userDetails == null) {
        print("⚠️ User details not found. Cannot register for the event.");
        return false;
      }

      // Extract user details
      String userId = userDetails['userId'];
      String userName = userDetails['name'];
      String userEmail = userDetails['email'];
      String userPhone = userDetails['phone'];

      // Create a new registration document in the database
      await database.createDocument(
        databaseId: databaseId,
        collectionId: eventsId,
        documentId: ID.unique(),
        data: {
          "user_id": userId,
          "event_id": eventId,
          "user_name": userName,
          "user_email": userEmail,
          "user_phone": userPhone,
        },
      );

      print("✅ Registration successful for user $userId to event $eventId");
      return true;
    } catch (e) {
      print("❌ Registration Error: $e");
      return false;
    }
  }

  /// **Fetch Events Created by Logged-in User**
  static Future<List<Map<String, dynamic>>> getMyEvents() async {
    try {
      String? userId = await getCurrentUserId(); // ✅ Fetch userId internally
      if (userId == null) return [];

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: eventCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      return response.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['image_url'] = (data['event_image_id'] != null &&
                data['event_image_id'].isNotEmpty)
            ? getImageUrl(data['event_image_id'])
            : "https://via.placeholder.com/250";
        return data;
      }).toList();
    } catch (e) {
      print('❌ Fetch My Events Error: $e');
      return [];
    }
  }

  /// **Fetch Event Categories from Appwrite**
  static Future<List<String>> fetchEventCategories() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: categoryId,
      );

      List<String> categories = response.documents.map((doc) {
        final categoryName =
            doc.data['category']?.toString().trim(); // Ensure clean data
        return categoryName?.isNotEmpty == true
            ? categoryName!
            : "Unknown Category";
      }).toList();

      print('✅ Event Categories Fetched: $categories');
      return categories;
    } catch (e) {
      print('❌ Fetch Event Categories Error: $e');
      return [];
    }
  }

  static Future<void> logoutUser() async {
    try {
      await account.deleteSession(sessionId: 'current');
      print("✅ User logged out successfully");
    } catch (e) {
      print("❌ Logout failed: $e");
    }
  }

  static Future<String?> getUserId() async {
    try {
      final response = await account.get();
      return response.$id; // Return the user ID from Appwrite response
    } catch (e) {
      print("Error fetching user ID: $e");
      return null; // Return null if the user is not logged in or an error occurs
    }
  }

  // Fetch the current logged-in user's details
  static Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      models.User user = await account.get(); // Get current user session
      String userEmail = user.email;

      // Query the collection to find the user by email
      models.DocumentList documents = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: userCollectionId,
        queries: [
          Query.equal("email", userEmail),
        ],
      );

      if (documents.documents.isNotEmpty) {
        final userData = documents.documents.first.data;
        return {
          'userId': user.$id, // ✅ Include User ID
          'name': userData['name'],
          'email': userData['email'],
          'phone': userData['phone'] ?? "Not provided",
          'profileImage': userData['profileImage'] ?? null,
          'createdAt': user.registration,
        };
      } else {
        print("⚠️ No user found in the database.");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user details from database: $e");
      return null;
    }
  }

  static String getImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/$bucketId/files/$fileId/view?project=67aa277600042d235f09';
  }
}
