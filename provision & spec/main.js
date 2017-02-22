// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
    response.success("Hello world!");
});
 
 
 
 
var pubnub = {
    'publish_key': 'pub-c-d3a94819-889f-4cca-9a8e-c6f6ea9dfcbf',
    'subscribe_key': 'sub-c-b30ccc46-bf36-11e5-8a35-0619f8945a4f'
};
 
 
 
 
 
 
var Stripe = require('stripe')('sk_test_SLpmMnVvroesOo6WjMbf8iIx');
//Stripe.initialize("sk_test_SLpmMnVvroesOo6WjMbf8iIx");
 
 
 
Parse.Cloud.define("chargeCustomer", function(request, response) {
 
    var amount = request.params["amount"];
    var currency = request.params["currency"];
    var customer = request.params["customer"];
    var card = request.params["card"];
 
    Stripe.Charges.create({
        'amount': amount,
        'currency': currency,
        'card': card,
        'customer': customer
    }, {
        success: function(results) {
            response.success(results);
 
        },
        error: function(error) {
            // body...
            response.error(error);
        }
    });
 
 
 
});
Parse.Cloud.define("chargeToken", function(request, response) {
 
    Stripe.Charges.create(
 
 
 
        request.params, {
            success: function(results) {
                response.success(results);
            },
            error: function(error) {
                response.error("Error:" + error);
            }
        }
    );
});
 
Parse.Cloud.define('createCustomer', function(request, response) {
 
 
    var email = request.params["email"];
    var name = request.params["name"];
 
    var userId = request.params["objectId"];
 
    Stripe.Customers.create({
        account_balance: 0,
        email: email,
        description: 'Alfred Customer',
        metadata: {
            name: name,
            userId: userId, // e.g PFUser object ID
            createWithCard: false
        }
    }, {
        success: function(httpResponse) {
            response.success(httpResponse); // return customerId
        },
        error: function(httpResponse) {
            console.log(httpResponse);
            response.error("Cannot create a new customer.");
        }
    });
 
 
 
 
});
 
 
Parse.Cloud.define("stripeAddCardToCustomer", function(request, response) {
 
 
    var customerId = request.params["customerId"];
    var cardTokenId = request.params["tokenId"];
    Parse.Cloud.httpRequest({
        method: "POST",
        url: "https://" + "sk_test_SLpmMnVvroesOo6WjMbf8iIx" + ':@' + "api.stripe.com/v1/customers/" + customerId + "/sources",
        body: {
            'source': cardTokenId
 
        },
        success: function(httpResponse) {
            response.success(httpResponse.text);
        },
        error: function(httpResponse) {
            response.error('Request failed with response code ' + httpResponse.status);
        }
    });
 
 
 
 
 
 
    // Stripe.Customers.update
    // (
    //     request.params["customerId"],
    //     {'card': cardTokenId},
    //     {
    //         success:function(results)
    //         {
    //             console.log(results["id"]);
    //             response.success(results);
    //         },
    //         error:function(error)
    //         {
    //             response.error("Error:" +error); 
    //         }
    //     }
    // );
 
 
 
});
 
 
Parse.Cloud.afterSave("BoardMessage", function(request) {
    var pushQuery = new Parse.Query(Parse.Installation);
 
    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: "A new message has been posted",
            sound: "default",
            badge: "Increment"
        }
    }, {
        useMasterKey: true,
        success: function() {
            response.success('true');
        },
        error: function(error) {
            response.error(error);
        }
    });
});
 
 
Parse.Cloud.afterSave("JoinRideRequest", function(request) {
    var pushQuery = new Parse.Query(Parse.Installation);
    var user = request.object.get("author");
 
    pushQuery.equalTo("user", user);
 
    Parse.Push.send({
        where: pushQuery,
        data: {
            alert: "Someone wants to join your ride, check it out",
            sound: "default",
            badge: "Increment"
        }
    }, {
        useMasterKey: true,
        success: function() {
            response.success('true');
        },
        error: function(error) {
            response.error(error);
        }
    });
});
 
Parse.Cloud.afterSave("UserLocation", function(request) {
 
    var pushQuery = new Parse.Query(Parse.Installation);
    var location = request.object.get("location");
 
    var latitude = location.latitude;
    var longitude = location.longitude;
    var user = request.object.get("user");
    //check if any ride request is active for user
 
    var RideRequest = Parse.Object.extend("RideRequest");
    var query = new Parse.Query(RideRequest);
    query.equalTo("driver", user);
    query.equalTo("accepted", true);
    query.notEqualTo("finished", true);
    query.notEqualTo("canceled", true);
    query.notEqualTo("canceledByDriver", true);
 
    query.find({
        success: function(results) {
            alert("Successfully retrieved " + results.length + " scores.");
            // Do something with the returned Parse.Object values
            for (var i = 0; i < results.length; i++) {
                var object = results[i];
                var pickupLat = object.get("pickupLat");
                var pickupLong = object.get("pickupLong");
                var rider = object.get("requestedBy");
 
 
                if (abs(pickupLat - latitude) < 100 && abs(pickupLong - longitude) < 100) {
 
                    //send push to rider saying driver is around
                    var pushQuery = new Parse.Query(Parse.Installation);
                    var user = request.object.get("author");
 
                    pushQuery.equalTo("user", rider);
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: "Alfred have arrived",
                            sound: "default",
                            badge: "Increment"
                        }
                    }, {
                        useMasterKey: true,
                        success: function() {
                            response.success('true');
                        },
                        error: function(error) {
                            response.error(error);
                        }
                    });
 
                }
 
 
 
 
            }
        },
        error: function(error) {
            alert("Error: " + error.code + " " + error.message);
        }
    });
 
 
 
    // Parse.Push.send({
    //       where: pushQuery,
    //       data: {
    //           alert: "Location updated",
    //           sound: "default",
    //           badge: "Increment"
    //             }
    //       },{
    //       useMasterKey: true,
    //       success: function(){
    //          response.success('true');
    //       },
    //       error: function (error) {
    //          response.error(error);
    //       }
    //     });
});
 
 
 
 
Parse.Cloud.afterSave("TakeRideRequest", function(request) {
 
     
 
    if(!request.object.existed()){
      request.object.get("boardMessage").fetch({
        success: function(msg) {
            msg.get("author").fetch({
                success: function(user) {
                    //have to use to send the push
                    var alertMsg = " An Alfred has replied to you. ";
                    //send push
 
 
                    var pushQuery = new Parse.Query(Parse.Installation);
 
 
                    pushQuery.equalTo("user", user);
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: alertMsg,
                            sound: "default",
                            badge: "Increment"
                        }
                    }, {
                        useMasterKey: true,
                        success: function() {
                            response.success('true');
                        },
                        error: function(error) {
                            response.error(error);
                        }
                    });
 
 
                },
                error: function() {
 
                }
 
 
            });
 
        },
        error: function() {
 
 
        }
    });
 
 
  }
});
 
 
Parse.Cloud.beforeSave(Parse.User, function(request, response) {
 
 
    var user = request.object;
 
    var enabledAsDriver = request.object.get('EnabledAsDriver');
 
    if (!request.object.isNew()) {
        if (enabledAsDriver === true) {
 
 
            var query = new Parse.Query("_User");
            query.get(request.object.id, { // Gets row you're trying to update
                success: function(row) {
 
                    if (row.get('EnabledAsDriver') !== true) {
 
                        //the state changed, it was false and now it is true
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", user);
 
                        Parse.Push.send({
                            where: pushQuery,
                            data: {
                                alert: "Your driver request was accepted.\n Now you can turn on driver mode.\n Welcome to our community",
                                sound: "default",
                                badge: "Increment",
                                key: "DRIVER_ENABLED"
                            }
                        }, {
                            useMasterKey: true,
                            success: function() {
                                response.success();
                            },
                            error: function(error) {
                                response.error(error);
                            }
                        });
 
                    }
                    response.success();
                },
                error: function(row, error) {
                    response.error(error.message);
                }
            }); // end of query
 
 
        } else { //end of enabled as driver true
            //the user is not enabled as driver
 
 
            var query = new Parse.Query(Parse.User);
 
            query.get(request.object.id, { // Gets row you're trying to update
                success: function(row) {
 
                    if (row.get('EnabledAsDriver') !== false) {
                        request.object.set("UserMode", true);
                        //the state changed, it was false and now it is true
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", user);
 
                        Parse.Push.send({
                            where: pushQuery,
                            data: {
                                alert: "Your driver mode has been disabled, please contact us for details",
                                sound: "default",
                                badge: "Increment",
                                key: "DRIVER_DISABLED"
                            }
                        }, {
                            useMasterKey: true,
                            success: function() {
                                response.success();
                            },
                            error: function(error) {
                                response.error(error);
                            }
                        });
 
                    } else {
 
                        response.success();
                    }
 
 
 
 
                },
                error: function(row, error) {
                    response.error(error.message);
                }
            });
        }
    } else {
 
 
        //the user is new
        response.success();
    }
 
 
 
 
});
 
 
Parse.Cloud.afterSave(Parse.User, function(request, response) {
 
 
    if (!request.object.existed()) {
        // new user was created
        // notify pubnub about it
        var message = {
            "from": "parse",
            "message": "New user created"
        };
 
        Parse.Cloud.httpRequest({
            url: 'http://pubsub.pubnub.com/publish/' +
                pubnub.publish_key + '/' +
                pubnub.subscribe_key + '/0/' +
                'signup' + '/0/' +
                encodeURIComponent(JSON.stringify(message)),
 
            // SUCCESS CALLBACK
            success: function(httpResponse) {
                console.log(httpResponse.text);
                // httpResponse.text -> [1,"Sent","14090206970886734"]
            },
 
            // You should consider retrying here when things misfire
            error: function(httpResponse) {
                console.error('Request failed ' + httpResponse.status);
            }
        });
 
    }
    response.success();
 
});
 
 
Parse.Cloud.beforeSave("RideRequest", function(request, response) {
 
    console.log("RideRequest beforeSave");
    if(request.object.isNew()){
      request.object.get("requestedBy").fetch({
        success: function(user) {
 
            request.object.get("driver").fetch({
                success: function(driver) {
 
                    var userName = user.get("FirstName");
                    var driverName = driver.get("FirstName");
                    if (!request.object.isNew()) {
 
 
 
                        var query = new Parse.Query("RideRequest");
                        query.get(request.object.id, { // Gets row you're trying to update
                            success: function(row) {
 
                                if (row.get('canceled') !== true && request.object.get('canceled') === true) {
 
                                    //the ride was canceled by the user
 
 
 
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo("user", driver);
 
                                    Parse.Push.send({
                                        where: pushQuery,
                                        data: {
                                            alert: userName + " has canceled the ride.",
                                            sound: "default",
                                            badge: "Increment",
                                            key: "RIDE_REQUEST_CANCELLED",
                                            "rid": row.id
                                        }
                                    }, {
                                        useMasterKey: true,
                                        success: function() {
                                            response.success();
                                        },
                                        error: function(error) {
                                            response.error(error);
                                        }
                                    });
 
                                } else if (row.get('canceledbyDriver') !== true && request.object.get('canceledbyDriver') === true) {
 
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo("user", user);
 
                                    Parse.Push.send({
                                        where: pushQuery,
                                        data: {
                                            alert: "Driver has canceled the ride",
                                            sound: "default",
                                            badge: "Increment",
                                            key: "RIDE_CANCELLED_BY_DRIVER"
                                        }
                                    }, {
                                        useMasterKey: true,
                                        success: function() {
                                            response.success();
                                        },
                                        error: function(error) {
                                            response.error(error);
                                        }
                                    });
 
                                } else if (row.get("accepted") !== true && request.object.get("accepted") === true) {
                                    var key = "RIDE_ACCEPT";
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo("user", request.object.get('requestedBy'));
 
                                    Parse.Push.send({
                                        where: pushQuery,
                                        data: {
                                            alert: driverName + " is on its way to pickup you.",
                                            sound: "default",
                                            badge: "Increment",
                                            key: key,
                                            rid: row.id,
                                            driverID: request.object.get('driver').objectId
                                        }
                                    }, {
                                        useMasterKey: true,
                                        success: function() {
                                            response.success();
                                        },
                                        error: function(error) {
                                            response.error(error);
                                        }
                                    });
 
                                } else if (row.get("rejected") !== true && request.object.get("rejected") === true) {
                                    var key = "RIDE_REJECTED_BY_DRIVER";
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo("user", request.object.get('requestedBy'));
 
                                    Parse.Push.send({
                                        where: pushQuery,
                                        data: {
                                            alert: "Your request was declined by " + driverName,
                                            sound: "default",
                                            badge: "Increment",
                                            key: key,
                                            rid: row.id,
                                            driverID: request.object.get('driver').objectId
                                        }
                                    }, {
                                        useMasterKey: true,
                                        success: function() {
                                            response.success();
                                        },
                                        error: function(error) {
                                            response.error(error);
                                        }
                                    });
 
 
                                } else if (row.get('finished') !== true && request.object.get('finished') === true) {
                                    //ride finished, send push to user
 
                                    var pushQuery = new Parse.Query(Parse.Installation);
                                    pushQuery.equalTo("user", request.object.get('requestedBy'));
 
                                    Parse.Push.send({
                                        where: pushQuery,
                                        data: {
                                            alert: "Hope you enjoyed your ride with Alfred\n, please leave feedback for your journey.",
                                            sound: "default",
                                            badge: "Increment",
                                            key: "RIDE_ENDED",
                                            rid: row.id,
                                            driverID: request.object.get('driver').objectId
                                        }
                                    }, {
                                        useMasterKey: true,
                                        success: function() {
                                            response.success();
                                        },
                                        error: function(error) {
                                            response.error(error);
                                        }
                                    });
 
                                }
 
 
                                response.success();
                            },
                            error: function(row, error) {
                                response.error(error.message);
                            }
                        });
 
 
                    } else {
 
                        response.success();
 
 
                    }
 
 
 
                }
 
            });
 
 
        }
 
    });
 
 
 
 
  }else{
 
      //no op
 
  }
 
 
 
});
 
 
Parse.Cloud.afterSave("RideRequest", function(request) {
    
    request.object.get("requestedBy").fetch({
    
    	success: function(user) {
                                            
    		request.object.get("driver").fetch({
    
    			success: function(driver) {
    
    				userName = user.get("FirstName");
				    driverName = driver.get("FirstName");
				                                       
				    console.log("RideRequest afterSave from " + userName + " to " + driverName);
				                      
				    if (!request.object.existed()) {
				        //the request is new, send push to the driver
				        var pushQuery = new Parse.Query(Parse.Installation);
				        pushQuery.equalTo("user", request.object.get('driver'));
				 
				        Parse.Push.send({
				            where: pushQuery,
				            data: {
				                alert: "Hello " + driverName + ", Do you want to take this ride?",
				                sound: "default",
				                badge: "Increment",
				                key: "RIDE_REQUEST",
				                "rid": request.object.id,
				                "seats": request.object.get("seats")
				            }
				        }, {
				            useMasterKey: true,
				            success: function() {
				                response.success();
				            },
				            error: function(error) {
				                response.error(error);
				            }
				        });
 
    				}
                                       
    			} // success: function(driver)
                                       
    		}); // request.object.get("driver").fetch
    
    	} // success: function(user)

    }); // request.object.get("requestedBy").fetch
 
});
 
 
 
Parse.Cloud.afterSave("RegistrationRequest", function(request) {
 
    if (!request.object.existed()) {
 
        Parse.Cloud.httpRequest({
            url: 'https://pubsub.pubnub.com/publish/pub-c-d3a94819-889f-4cca-9a8e-c6f6ea9dfcbf/sub-c-b30ccc46-bf36-11e5-8a35-0619f8945a4f/0/registration_request/0/"NewRequest"',
            // successful HTTP status code
            success: function(httpResponse) {
                console.log(httpResponse.text);
            },
            // unsuccessful HTTP status code
            error: function(httpResponse) {
                console.error('Request failed with response code ' + httpResponse.status);
            }
        });
 
    }
 
 
 
});
 
 
 
//this is for the cms
//when a new object is created we send a push to the user with the
//message
 
Parse.Cloud.afterSave("PushNotifications", function(request, response) {
 
 
    if (!request.object.existed()) {
 
 
        // existed return false if the previous network operation crated the object
 
        //get the array with the target users id
        var targets = request.object.get('target');
 
 
        var message = request.object.get('message');
        var firstTarget = targets[0];
 
        var deliveryDate = request.object.get('deliveryDate');
 
        var userQuery = new Parse.Query(Parse.User);
 
 
        console.log('target: ' + firstTarget);
        userQuery.equalTo('objectId', firstTarget);
 
        userQuery.first({
            success: function(object) {
                // object contains the user to send the push
                var pushQuery = new Parse.Query(Parse.Installation);
                pushQuery.equalTo("user", object);
 
                Parse.Push.send({
                    where: pushQuery,
                    data: {
                        alert: message,
                        sound: "default",
                        badge: "Increment"
                    }
                }, {
                    useMasterKey: true,
                    success: function() {
                        response.success();
                    },
                    error: function(error) {
                        response.error(error);
                    }
                });
 
 
 
 
            },
            error: function(error) {
                response.error();
            }
 
 
 
        });
 
 
    }
 
 
 
 
});
