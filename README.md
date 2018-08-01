# Memories

A student that completes this project shows that they can:

- request user permission to access private information (camera, microphone, photos, notifications, etc.)
- query to find out if user has previously allowed or denied permission
- make user permission-related code conditional on simulator
- schedule local notifications
- handle local notifications when they fire

## Introduction

Memories will help you solidify concepts such as scheduling notifications, asking user permission and basic persistence.

Please look at the screen recording below to know what the finished project should look like:

![](https://user-images.githubusercontent.com/16965587/43541006-8694ec74-9586-11e8-9b54-f59bdeb00479.gif)

## Instructions

Please fork and clone this repository. This repository does not have a starter project, so create one inside of the cloned repository folder.

### Part 1 - Data Model Set Up

#### Memory

1. Make a new Swift file called "Memory.swift". Create a struct called `Memory`. 
2. Add the following properties:
    - A variable called `title`.
    - A variable called `bodyText`.
    - A variable called `imageData`. Its type should be `Data`.
3. As you will be persisting instances this model object in a plist using `FileManager`, make this struct conform to `Codable`. Also make it conform to `Equatable`.

#### MemoryController

1. Create a "MemoryController.swift" file, and create a `MemoryController` model controller class.
2. Add a `var memories: [Memory]` array and set intial value to an empty array.
3. Add a `persistentFileURL` computed property that uses the `FileManager` class to get the document directory URL and append a filename and extension for the plist such as "memories.plist" to it, then returns that URL. (Refer to past projects, if needed)
4. Create a `saveToPersistentStore()` function that uses a `PropertyListEncoder` to encode the `memories` array and write that data to the device's storage using the `persistentFileURL` computed property.
5. Create a `loadFromPersistentStore()` method that will get the plist data from the `persistentFileURL` using the `Data(contentsOf: URL)` initializer. Using a `PropertyListDecoder`, decode the memories plist data back into an array of `Memory` objects. Set the model controller's `memories` variable to these newly decoded `Memory` objects.
6. Create a "Create" method that takes in the necessary parameters to initialize a `Memory` object. As always, append it to the `memories` variable, and call `saveToPersistentStore()`.
7. Create an "Update" method that will allow any (and all) properties to be updated on a `Memory` object. Remember to persist the updated object by calling `saveToPersistentStore()`.
8. Create a "Delete" function that deletes a `Memory` object. Persist this deletion.

### Part 2 - Storyboard Set Up

Memories uses the master-detail pattern. Additionally, there will be a small "onboarding" experience when first launching the application. It will explain what the application does, and it will explain that the application will be asking permission for a few things such as notifications and access to the user's photo library.

1. Add a `UIViewController` scene. This is the onboarding screen. Add two labels and a button to the scene, and constrain them as you see fit. They don't have to be the same as the screen recording.
    - One label will say: "Welcome to Memories!".
    - The other label will show: "We're going to help you document every day of your life. In order to do this, we need you to allow the application to send you notifications so you can be reminded to create a memory every day! We'll also ask for your permission to access your photo library to attach photos to your memories." **HINT:** In the attributes inspector, change the number of lines for the label to 0. This will allow the text to go onto a new line.
    - Change the button's title to "Get Started!".
    - Create a Cocoa Touch subclass of `UIViewController` called `OnboardingViewController`. Set the scene's class to it in the storyboard. Add an action from the "Get Started" button.
    - Set this scene as the initial view controller.
2. Drag out a `UITableViewController` and another `UIViewController` scene. These will form the master-detail part of the application. Embed the table view controller scene in a navigation controller.

You will now do something you may not have done in the past, which is a "Manual Segue". _Manual Segues_ are just like the segues that you are used to, however the difference is that instead of triggering the segue from tapping a button, cell, etc., the segue is triggered manually in code, hence the name.

3. Create a manual segue from the onboarding view controller scene to the navigation controller. To do this, select the yellow view controller icon above the scene or in the Document Outline. From it, control and drag to the navigation controller just like you would with a normal segue. Select "Present Modally". This will make it so the user can't come back to the onboarding view controller. It will be explained why you are doing this later on in the view controller implementation.
4. On the table view controller scene:
    - Set the cell's style to "Basic" and give it an appropriate identifier. 
    - Create a segue from the cell to the detail view controller and give it an identifier as well.
    - Add a bar button item to the navigation item. Set its "System Item" to "Add".
    - Create a segue from the bar button item to the detail view controller and give it an identifier.
    - Create a Cocoa Touch subclass of `UITableViewController` called `MemoriesTableViewController`.
5. On the detail view controller scene:
    - Add a `UIImageView`, a `UIButton`, a `UITextField`, and a `UITextView`. Again, constrain them however you wish.
    - Change the button's title to "Add Photo".
    - Add a navigation item to the view controller, then a bar button item to the navigation item. Set the bar button item's "System Item" to "Save".
    - Create a Cocoa Touch subclass of `UIViewController` called `MemoryDetailViewController`. Set the detail view controller scene's class to it. Add outlets from the image view, text field, and text view. Add actions from the "Add Photo" button, and the save bar button item.

### Part 3 - Local Notifications and Onboarding

#### LocalNotificationHelper

1. Create a "LocalNotificationHelper.swift" file. Create a class called `LocalNotificationHelper`. This class will help facilitate the process of requesting notification authorization from the user, checking the authorization status, and actually creating a notification.
2. Add these two functions to the class:

``` Swift
 func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            
            if let error = error { NSLog("Error requesting authorization status for local notifications: \(error)") }
            
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
```

These two functions are the same for any application, so you are welcome to make a code snippet of them if you want.

3. Create a function called `scheduleDailyReminderNotification()`. This function should set up a local notification to fire every day at 8 PM. The purpose of the notification is to remind them to create a memory for the day.
    - **HINT:** A notification is scheduled using a `UNNotificationRequest`. The request needs an `identifier` string, a trigger (try using `UNCalendarNotificationTrigger`), and the content that is the information to be shown to the user (`UNMutableNotificationContent`). 

#### OnboardingViewController

As previously stated, the onboarding view controller is going to be shown to the user when they launch the app for the first time. It's generally a bad user experience to immediately request authorization to send them notifications as soon as they run the app. An onboarding style view controller is a way to solve this problem, and increase their chances of actually giving the application authorization. 

The message in one of the labels will explain **why** we need to send them notifications. You will make it so the authorization request only appears when they tap the "Get Started!" button. This is the reason you are using the manual segue, instead of triggering the segue automatically when the button is tapped. We want to request authorization, and only after we have that authorization do we want to segue to the rest of the application.

1. Create a constant called `localNotificationHelper` that creates a new instance of `LocalNotificationHelper`.
2. In the button's action, call the `requestAuthorization` function of the `localNotificationHelper`. In the completion closure of this function, if it was successful, call the `scheuleDailyReminderNotification()` function. At this point, the onboarding view controller has done its job, so you can move the user to the main part of the application. To do this, trigger the manual segue by calling `performSegue(withIdentifier: String, sender: Any?)`. The identifier should be the segue's identifier that you assigned in the storyboard between the onboarding view controller and the navigation controller. You can pass `nil` in for the `sender`.
3. Using the `localNotificationHelper`, call the `getAuthorizationStatus` method in the `viewDidLoad()`. This will allow you to check the current local notification authorization status, whether it has already been authorized, rejected, or not been requested at all. Since this onboarding view controller is meant only to ask the user for that authorization, create a conditional statement that will check the value of the status returned in the completion closure of the `getAuthorizationStatus` function. If the user has already authorized local notifications, then perform the manual segue to send them straight to the table view controller.

### Part 4 - Master-Detail Implementation

#### MemoriesTableViewController

So that you can set up the `prepare(for segue: ...)` method of the table view controller, go to the `MemoryDetailViewController` and add the following:
  - `var memory: Memory?`
  - `var memoryController: MemoryController`

This table view controller implementation is very simple, and you should be well versed in setting them up by now. As such, please try to fill it out by yourself. You will need to implement the `numberOfRowsInSection`, `cellForRowAt`, `commit editingStyle`, and `prepare(for segue: ...)` methods. Also make sure the table view reloads upon coming back to this view controller in the `viewWillAppear` method. 

Apple-made cell styles come with an image view just like they do a text label and (potentially) a detail text label. However, it is hidden unless you give it an image. Using the `imageData` property on `Memory`, give each cell an image along with the title of the `Memory`.
 - **HINT:** In order to put the memory's `imageData` in the image view's `image` property, you must convert the data to a `UIImage`. To do so, use the `UIImage(data: Data)` initializer.

#### MemoryDetailViewController

1. Create an `updateViews` function. This should take the `memory` object and unwrap it. If the memory is `nil`, set the view controller's title to "Add Memory". If it does exist, unwrap it and set the view controller's title to "Edit Memory". Also set the `memory` object's values inside of the corresponding outlets.
2. In the bar button item's action, it should update the `memory` if it exists, or create a new one if it is `nil.

This view controller will make use of a special view controller called a `UIImagePickerController`. It will allow the user to access their photo library inside of the application, while you have to write minimal code to do so. The image picker controller's UI is already laid out for you, so it will look as if the user is using the Photos app inside of your app. 

3. Create a function called `presentImagePickerController()`. Inside of this function:
    - Use the `.isSourceTypeAvailable` **class** function on `UIImagePickerController` to check if the photo library is available on the current device. If it isn't, return out of the function; there is nothing that you can do if it isn't available.
    - If it is available however, create a constant called `imagePicker` and set its value to a new instance of `UIImagePickerController`.
    - Set the `imagePicker`'s `sourceType` to `.photoLibrary`.
    - Set the `imagePicker`'s `delegate` to `self`. Xcode will likely be throwing errors because you do not conform to the `UIImagePickerControllerDelegate` protocol. Adopt it in this view controller. You will also need to adopt the `UINavigationControllerDelegate` protocol.
    - Use the view controller's `present` method and pass in the `imagePicker`. This will make the image picker appear to the user. Select `true` for the `animated` parameter, then `nil` for the `completion` parameter

Once the user selects an image from the image picker, it isn't accessible to us at this point. The image picker won't even dismiss itself automatically. Luckily, the `didFinishPickingMediaWithInfo` method that is a part of `UIImagePickerControllerDelegate` will give us access to the photo, and the ability to dismiss the image picker.

4. Call the `didFinishPickingMediaWithInfo` method. Inside this function:
    - Access the image picker by using the `picker` parameter of the function. Call the `dismiss` method. Again pass in `true` for `animated`, then `nil` for the `completion` parameter. This will cause the image picker to be dismissed from the screen and show the detail view controller again.
    - The other parameter we get access to in this method is an `info` dictionary. Among other things, the dictionary contains the `UIImage` that the user selected. Create a constant for the image and set its value to `info[UIImagePickerControllerOriginalImage] as? UIImage`. That long key is a pre-made key property so we can avoid using a magic string and potentially mess it up.
    - Set the image view's `image` equal to this new `UIImage` constant.

5. Before we are able to present the image picker controller to the user, we need to request authorization for the application to access their photo library in the first place. In order to do this:
  - In the action of the "Add Photo" button, you may gain access to the current authorization status of the photo library by using `PHPhotoLibrary.authorizationStatus()`. It will return the authorization status in that function. Make a constant for the returned status called `authorizationStatus`.
  - Using a conditional statement, check the `authorizationStatus`'s value. If it is `.authorized`, then call the `presentImagePickerController()` method.
  - If the `authorizationStatus` is `.notDetermined`, that means the user hasn't been asked for authorization before. Call the `PHPhotoLibrary.requestAuthorization` method. In its completion closure it will return another authorization status. Check this one to see if its value is `.authorized`. If so, present the image picker controller.
  - In order to request authorization, we must add a key-value pair to the info.plist file. Add the key called "Privacy - Photo Library Usage Desription", and add a string value that will explain the reason you are asking permission to access their photo library. Note that this string will be shown to the user when you request authorization. Failure to add this key-value pair will result in the application crashing when you request their authorization.
  
## Go Further

- You may have noticed that we aren't handling every single case for the authorization status in the "Add Photo" button's action. In a real application, you absolutely would. Handle every case for the `PHAuthorizationStatus`. Present an alert to the user if the authorization status is `.denied` or `restricted`.
