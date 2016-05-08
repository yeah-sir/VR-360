# VR-360

(Due to the large size of files in the Unity project, the code is uploaded to dropbox: https://www.dropbox.com/sh/nu3kgm5efojznl0/AACR46wQmXmkTBbWcIckhfHGa?dl=0 )

An iOS application that helps you look up 360 images to be viewed on cardoard apps based on time and location.

### Technologies used

* Unity
* Google Cardboard API
* Android and iOS SDKs
* Amazon Alexa
* IBM Natural Language Classifier
* AWS Lambda functions
* Flickr

### Implementation

- Unity was used as the display platform along with the Google Cardboard plugin to create a VR experience. The VR experience consits of a
landing page with a curved grid view that covers the users view port. It moves slightly as a call to action for it being the main interface
for interacting with the app.

- Google Cardboard API was used so as to make the app portable to iOS and Android. Currently iOS devices do not have the capability of taking
cardboard ready VR images. Our app uses curated content from users in order to provide this experience to iOS users. 

- The Unity app has iOS and Android builds

- Since user interaction is minimal while using cardboard it was important to come up with alternative interactions. So as to make the
experience as immersive as possible we used voice input so that user does not have to take off the mobile device from the cardboard in order
to interact with the app. Amazon Alexa served as our primary mode of taking user input in the form of voice intents in the form of
"Show me pictures from New York in the evening" or "Techcrunch at 3am"

- IBM Natural Language Classifiers was used to convert the different ways time related information might be stated by the user into classes
of time understood by the app. The classifier uses four buckets : "day", "night", "sunrise" and "sunset" which serve as time related tags
for the images.

- AWS Lambda functions provided serverless microservices that were used for setting up the Amazon echo intent logics and an API for Unity to
search image URLs from Flicker based on the voice input that from Alexa after it was parsed by the IBM NLC logic.

- Flickr served as the storage for our images to be stored with tags that could be interpreted by the image serach API
