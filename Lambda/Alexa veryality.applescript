/**
 * This sample demonstrates a simple skill built with the Amazon Alexa Skills Kit.
 * The Intent Schema, Custom Slots, and Sample Utterances for this skill, as well as
 * testing instructions are located at http://amzn.to/1LzFrj6
 *
 * For additional samples, visit the Alexa Skills Kit Getting Started guide at
 * http://amzn.to/1LGWsLG
 */

// Route the incoming request based on type (LaunchRequest, IntentRequest,
// etc.) The JSON body of the request is provided in the event parameter.

var AWS = require("aws-sdk");
AWS.config.region = 'us-east-1';


exports.handler = function (event, context) {
    try {
        console.log("event.session.application.applicationId=" + event.session.application.applicationId);

        /**
         * Uncomment this if statement and populate with your skill's application ID to
         * prevent someone else from configuring a skill that sends requests to this function.
         */
        /*
        if (event.session.application.applicationId !== "amzn1.echo-sdk-ams.app.[unique-value-here]") {
             context.fail("Invalid Application ID");
        }
        */

        if (event.session.new) {
            onSessionStarted({requestId: event.request.requestId}, event.session);
        }

        if (event.request.type === "LaunchRequest") {
            onLaunch(event.request,
                event.session,
                function callback(sessionAttributes, speechletResponse) {
                    context.succeed(buildResponse(sessionAttributes, speechletResponse));
                });
        } else if (event.request.type === "IntentRequest") {
            onIntent(event.request,
                event.session,
                function callback(sessionAttributes, speechletResponse) {
                    context.succeed(buildResponse(sessionAttributes, speechletResponse));
                });
        } else if (event.request.type === "SessionEndedRequest") {
            onSessionEnded(event.request, event.session);
            context.succeed();
        }
    } catch (e) {
        context.fail("Exception: " + e);
    }
};

/**
 * Called when the session starts.
 */
function onSessionStarted(sessionStartedRequest, session) {
    console.log("onSessionStarted requestId=" + sessionStartedRequest.requestId +
        ", sessionId=" + session.sessionId);
}

/**
 * Called when the user launches the skill without specifying what they want.
 */
function onLaunch(launchRequest, session, callback) {
    console.log("onLaunch requestId=" + launchRequest.requestId +
        ", sessionId=" + session.sessionId);

    // Dispatch to your skill's launch.
    /////////    getSQSMessage(callback);
    getWelcomeResponse(callback);
    
}

/**
 * Called when the user specifies an intent for this skill.
 */
function onIntent(intentRequest, session, callback) {
    console.log("onIntent requestId=" + intentRequest.requestId +
        ", sessionId=" + session.sessionId);

    var intent = intentRequest.intent,
        intentName = intentRequest.intent.name;

    // Dispatch to your skill's intent handlers
    if ("MySearchedPlaceIntent" === intentName) {
        setSearchedPlace(intent, session, callback);
    } else if ("WhatsMyColorIntent" === intentName) {
        getWelcomeResponse(intent, session, callback);
    } else if ("AMAZON.HelpIntent" === intentName) {
        getWelcomeResponse(callback);
    }
    else if ("ChangeScreenIntent" === intentName) {
        setNewScreen(intent, session, callback);
    }
    else if ("HideUIIntent" === intentName) {
        hideUI(intent, session, callback);
    } else {
        throw "Invalid intent";
    }
}

/**
 * Called when the user ends the session.
 * Is not called when the skill returns shouldEndSession=true.
 */
function onSessionEnded(sessionEndedRequest, session) {
    console.log("onSessionEnded requestId=" + sessionEndedRequest.requestId +
        ", sessionId=" + session.sessionId);
    // Add cleanup logic here
}

// --------------- Functions that control the skill's behavior -----------------------

function getWelcomeResponse(callback) {
    // If we wanted to initialize the session to have some attributes we could add those here.
    var sessionAttributes = {};
    var cardTitle = "Welcome";
    var speechOutput = "Hi, Welcome to the unity integration example";
    // If the user either does not reply to the welcome message or says something that is not
    // understood, they will be prompted again with this text.
    var repromptText = "Please tell me your favorite color by saying, " +
        "my favorite color is red";
    var shouldEndSession = false;
    callback(sessionAttributes,
                        buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
   


}

function getSQSMessage(callback) {
    // If we wanted to initialize the session to have some attributes we could add those here.
    
    
    var sessionAttributes = {};
    var cardTitle = "Welcome";
    var speechOutput = "we haven't read SQS yet";
    var repromptText = "";
    var shouldEndSession = false;
    //SQS here
    
     var qurl = 'https://sqs.us-east-1.amazonaws.com/914537066192/veryalitycommands'; 
    // TODO - change to Evans sqs url
    // https://sqs.us-east-1.amazonaws.com/697426589657/veryality
    //var qurl = 'https://sqs.us-east-1.amazonaws.com/697426589657/veryality';
    
    var queue = new AWS.SQS({params: {QueueUrl: qurl.toString()}});
    var deleteEnabled = true;
    params = {};
    console.log("queue ready");
    
        queue.receiveMessage(params, function (err, data){
            if (err) {
                console.log(err, err.stack)
                console.log("read error")
                deleteEnabled=false;
                }
            else if (typeof data.Messages != 'undefined') {
                //console.log(data.Messages);
                console.log("message Received");
                
                
                //update what alexa says
                speechOutput = data.Messages[0].Body;
                console.log("message 0: "+data.Messages[0]);
                
                
                //delete message
                if (deleteEnabled) {
                    var params = {
                            // TODO - change to Evans sqs url
    				  QueueUrl: 'https://sqs.us-east-1.amazonaws.com/914537066192/veryalitycommands', /* required */
    				  //QueueUrl: 'https://sqs.us-east-1.amazonaws.com/697426589657/veryality', /* required */
    				  ReceiptHandle: data.Messages[0].ReceiptHandle /* required */
    				};
    				
    				queue.deleteMessage(params, function(err, data) {
    				  if (err) 
    				  { 
    				      console.log(err, err.stack); // an error occurred
    				      console.log("error deleting");
    				    callback(sessionAttributes,
                        buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
    				  } else {
    				  console.log(data);     
    				    console.log("deleted"); 
                        callback(sessionAttributes,
                        buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
    				  }    
    				  
                      
    
    				});
                }

                

            } else {
                    callback(sessionAttributes,
                    buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
            }
            
        });
        
        


}


//===========================================================================

function hideUI(intent, session, callback){
    var cardTitle = intent.name;
    var hideUI = intent.slots.HideUI;
    var repromptText = "";
    var sessionAttributes = {};
    var shouldEndSession = true;
    var speechOutput = "";

    if (hideUI) {
        var whattohide = HideUI.value;
        sessionAttributes = createFavoriteColorAttributes(hideUI);
        speechOutput = "I will hide " + hideUI;
        repromptText = "";
        
        // TODO - change to Evans sqs url
        var qurl = 'https://sqs.us-east-1.amazonaws.com/914537066192/veryalitycommands';
        //var qurl = 'https://sqs.us-east-1.amazonaws.com/697426589657/veryality';
        var queue = new AWS.SQS({params: {QueueUrl: qurl.toString()}});
        var params = {
            //MessageBody: "search " + place
            MessageBody: whattohide 
        }
        
        queue.sendMessage(params, function (err, data){
            if (err) console.log(err, err.stack);
            else {
                console.log("message Sent");
                //callback goes here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
            }
            
        })
        
     
        
        
    } else {
        speechOutput = "I'm not sure what your favorite color is. Please try again";
        repromptText = "I'm not sure what your favorite color is. You can tell me your " +
            "favorite color by saying, my favorite color is red";
            
        //made callback hell here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
    }

    //this is where the callbcak should be rewrite with asnyc
    // callback(sessionAttributes,
   //         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
}




//===========================================================================

function setNewScreen(intent, session, callback) {
    var cardTitle = intent.name;
    var newScreenSlot = intent.slots.NewScreen;
    var repromptText = "";
    var sessionAttributes = {};
    var shouldEndSession = true;
    var speechOutput = "";

    if (newScreenSlot) {
        var screen = newScreenSlot.value;
        sessionAttributes = createFavoriteColorAttributes(screen);
        speechOutput = "OK, displaying " + screen ;
        repromptText = "";
        
        // TODO - change to Evans sqs url
        var qurl = 'https://sqs.us-east-1.amazonaws.com/914537066192/veryalitycommands';
        //var qurl = 'https://sqs.us-east-1.amazonaws.com/697426589657/veryality';
        var queue = new AWS.SQS({params: {QueueUrl: qurl.toString()}});
        var params = {
            //MessageBody: "search " + place
            MessageBody: screen
        }
        
        queue.sendMessage(params, function (err, data){
            if (err) console.log(err, err.stack);
            else {
                console.log("message Sent");
                //callback goes here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
            }
            
        })
        
     
        
        
    } else {
        speechOutput = "I'm not sure what your favorite color is. Please try again";
        repromptText = "I'm not sure what your favorite color is. You can tell me your " +
            "favorite color by saying, my favorite color is red";
            
        //made callback hell here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
    }

    //this is where the callbcak should be rewrite with asnyc
    // callback(sessionAttributes,
   //         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
}


/**
 * Sets the color in the session and prepares the speech to reply to the user.
 */
function setSearchedPlace(intent, session, callback) {
    var cardTitle = intent.name;
    var placeSlotSearch = intent.slots.Place;
    var repromptText = "";
    var sessionAttributes = {};
    var shouldEndSession = true;
    var speechOutput = "";

    if (placeSlotSearch) {
        var place = placeSlotSearch.value;
        sessionAttributes = createFavoriteColorAttributes(place);
        speechOutput = "I now know your search is for " + place ;
        repromptText = "";
        
        // TODO - change to Evans sqs url
        var qurl = 'https://sqs.us-east-1.amazonaws.com/914537066192/veryalitycommands';
        //var qurl = 'https://sqs.us-east-1.amazonaws.com/697426589657/veryality';
        var queue = new AWS.SQS({params: {QueueUrl: qurl.toString()}});
        var params = {
            //MessageBody: "search " + place
            MessageBody: place
        }
        
        queue.sendMessage(params, function (err, data){
            if (err) console.log(err, err.stack);
            else {
                console.log("message Sent");
                //callback goes here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
            }
            
        })
        
     
        
        
    } else {
        speechOutput = "I'm not sure what your favorite color is. Please try again";
        repromptText = "I'm not sure what your favorite color is. You can tell me your " +
            "favorite color by saying, my favorite color is red";
            
        //made callback hell here
         callback(sessionAttributes,
         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
    }

    //this is where the callbcak should be rewrite with asnyc
    // callback(sessionAttributes,
   //         buildSpeechletResponse(cardTitle, speechOutput, repromptText, shouldEndSession));
}

function createFavoriteColorAttributes(favoriteColor) {
    return {
        favoriteColor: favoriteColor
    };
}

function getColorFromSession(intent, session, callback) {
    var favoriteColor;
    var repromptText = null;
    var sessionAttributes = {};
    var shouldEndSession = false;
    var speechOutput = "";

    if (session.attributes) {
        favoriteColor = session.attributes.favoriteColor;
    }

    if (favoriteColor) {
        speechOutput = "Your favorite color is " + favoriteColor + ". Goodbye. oh, and by the way, You have nice hair today.";
        shouldEndSession = true;
    } else {
        speechOutput = "I'm not sure what your favorite color is, you can say, my favorite color " +
            " is red";
    }

    // Setting repromptText to null signifies that we do not want to reprompt the user.
    // If the user does not respond or says something that is not understood, the session
    // will end.
    callback(sessionAttributes,
         buildSpeechletResponse(intent.name, speechOutput, repromptText, shouldEndSession));
}

// --------------- Helpers that build all of the responses -----------------------

function buildSpeechletResponse(title, output, repromptText, shouldEndSession) {
    return {
        outputSpeech: {
            type: "PlainText",
            text: output
        },
        card: {
            type: "Simple",
            title: "SessionSpeechlet - " + title,
            content: "SessionSpeechlet - " + output
        },
        reprompt: {
            outputSpeech: {
                type: "PlainText",
                text: repromptText
            }
        },
        shouldEndSession: shouldEndSession
    };
}

function buildResponse(sessionAttributes, speechletResponse) {
    return {
        version: "1.0",
        sessionAttributes: sessionAttributes,
        response: speechletResponse
    };
}