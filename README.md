# TODO Share App

This is a collaborative TODO list application built using **Flutter**, **Provider**, and **Cloud Firestore**. Users can create tasks and share them in real-time with receivers via email and other platforms. Receivers can accept, reject, or update the task description. The UI is responsive, smooth with animation, and uses MVVM architecture for better separation of concerns.

---

## 🧠 Architecture

This app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Model:** Firestore collections for `users` and `tasks`
- **View:** `SenderView`, `ReceiverView`, and other UI widgets
- **ViewModel:** `SenderViewModel` and `ReceiverViewModel` handle business logic

Provider is used for state management to ensure UI updates on data changes.

---

## 📱 Features

### 🔵 Sender View
- Input task title, description, and receiver email
- Optional checkbox to enable email sharing
- Task is saved to Firestore
- Tasks list updates in real-time with shimmer loading
- Conditional email/message sharing using `share_plus`

### 🟢 Receiver View
- Lists all available receivers
- Shows assigned tasks for the selected receiver
- Accept/Reject tasks
- Update task description in real-time

---


--

### 🚀 How It Works

- Sender selects role** and enters task info.
- Firestore stores** task and user if not already present. 
- If enabled, **email/share intent opens** to notify receiver. 
- Receiver views their tasks** in real-time. 
- They can **accept/reject** or **update description** which reflects back to sender.

---

## 📌 Notes
- All real-time updates are powered by Firestore Streams.
- UI states are handled using `ChangeNotifier` and `Provider`.
- Email notification is handled using `share_plus` (can be upgraded to Cloud Functions).


## 🛠️ Firestore Database Structure



### Collection: `users`
Each document ID is the user's email:

```json
{
  "email": "receiver@email.com",
  "createdAt": Timestamp
}

{
  "title": "Oil Change",
  "description": "Perform oil change on vehicle",
  "sender": "sender@email.com",
  "receiver": "receiver@email.com",
  "accepted": null | true | false,
  "timestamp": Timestamp,
  "sendEmail": true | false
}


