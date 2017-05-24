
 
var Stripe = require('stripe')('sk_test_zd4wzarlbkV9p8hQuoI00zEj');//('sk_test_SLpmMnVvroesOo6WjMbf8iIx');

//console.log(Stripe);
 
///////// Create customer /////////
Parse.Cloud.define('createCustomer', function(request, response) {
 
    console.log("============= createCustomer ==============");
 
    var email = request.params["email"];
    var name = request.params["name"];
    var stripeToken = request.params["stripeToken"];
    var userId = request.params["objectId"];
 
    Stripe.customers.create({
        account_balance: 0,
        email: email,
        description: 'Alfred Customer',
        metadata: {
            name: name,
            userId: userId, // e.g PFUser object ID
            createWithCard: false
        }
    }, function(error, customer) {
        if (error) {
            response.error(error);
        } else {
            response.success(customer);
        }
    });

});

 
Parse.Cloud.define("chargeCustomer", function(request, response) {
 
    console.log("============= chargeCustomer ==============");

    var amount = request.params["amount"];
    var currency = request.params["currency"];
    var customer = request.params["customer"];
    var card = request.params["card"];
 
    Stripe.charges.create({
        'amount': amount,
        'currency': currency,
        'card': card,
        'customer': customer
    }, function(error, results) {
        if (error) {
            response.error(error);
        } else {
            response.success(results);
        }
    });
});


Parse.Cloud.define("chargeToken", function(request, response) {
 
    console.log("============= chargeToken ==============");

    Stripe.Charges.create(request.params, {
            success: function(results) {
                response.success(results);
            },
            error: function(error) {
                response.error("Error:" + error);
            }
        }
    );
});


///////// Stripe add card to customer /////////
Parse.Cloud.define("stripeAddCardToCustomer", function(request, response) {
 
    console.log("============= stripeAddCardToCustomer ==============");

    var customerId = request.params["customerId"];
    var cardTokenId = request.params["tokenId"];
    Parse.Cloud.httpRequest({
        method: "POST",
        url: "https://" + "sk_test_zd4wzarlbkV9p8hQuoI00zEj" + ':@' + "api.stripe.com/v1/customers/" + customerId + "/sources",
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
});


Parse.Cloud.afterSave("RegistrationRequest", function(request) {

    if (!request.object.existed()) {
 
        Parse.Cloud.httpRequest({
            url: 'https://pubsub.pubnub.com/publish/pub-c-d3a94819-889f-4cca-9a8e-c6f6ea9dfcbf/sub-c-b30ccc46-bf36-11e5-8a35-0619f8945a4f/0/registration_request/0/"NewRequest"',
            // successful HTTP status code
            success: function(httpResponse) {
                //console.log(httpResponse.text);
            },
            // unsuccessful HTTP status code
            error: function(httpResponse) {
                console.error('Request failed with response code ' + httpResponse.status);
            }
        });
 
    }
});



///////// Retrieve User object /////////
Parse.Cloud.define("GetUser", function(request, response) {

    var userQuery = new Parse.Query("_User");
    userQuery.get(request.params.userId, {

        useMasterKey: true,

        success: function(user) {

            response.success(user);

        },

        error: function(error) {
            response.error(error);
        }

    });

});

//////////////// Update User Location ////////////////
Parse.Cloud.define("UpdateUserLocation", function(request, response) {

    request.user.set("location", request.params.location);
    request.user.set("locationAddress", request.params.locationAddress);
    request.user.save(null, {useMasterKey: true});

    response.success(request.user);

});

//////////////// Create Driver Pathway ////////////////
Parse.Cloud.define("CreateDriverPathway", function(request, response) {

    // First, delete all garbage pathways because
    // pathway can exist only one at a moment
    var deleteQuery = new Parse.Query("DriverPathway");
    deleteQuery.equalTo("driver", request.user);
    deleteQuery.find({

        useMasterKey: true,

        success: function(pathways) {
            pathways.forEach(function(pathway) {
                pathway.destroy({useMasterKey: true});
            });

            // And create new pathway
            var DriverPathway = Parse.Object.extend("DriverPathway");
            var pathway = new DriverPathway();

            pathway.set("driver", request.user);
            pathway.set("destination", request.params.destination);
            pathway.set("destinationAddress", request.params.destinationAddress);
            pathway.set("numberOfSeats", request.params.numberOfSeats);
            pathway.set("availableSeats", request.params.numberOfSeats);
            pathway.set("ladiesOnly", request.params.ladiesOnly);
            pathway.set("pricePerSeat", request.params.pricePerSeat);

            pathway.save(null, {

                useMasterKey: true,

                success: function(saved_pathway) {
                    response.success(saved_pathway);
                },

                error: function(error) {
                    response.error(error);
                }

            });

        },

        error: function(error) {
            response.error(error);
        }

    });

});

///////// Query Driver Pathway For Passenger /////////
Parse.Cloud.define("QueryDriverPathways", function(request, response) {

    // pickup and drop-off locations
    var pickupLocation = request.params.pickupLocation;
    var dropoffLocation = request.params.dropoffLocation;
            
    var queryDrivers = new Parse.Query("_User");
    queryDrivers.equalTo("UserMode", true);
    queryDrivers.withinKilometers("location", pickupLocation, 5);

    var queryPathways = new Parse.Query("DriverPathway");
    queryPathways.greaterThan("availableSeats", 0);
    queryPathways.matchesQuery("driver", queryDrivers);
    queryPathways.include("driver");

    queryPathways.find({

        useMasterKey: true,

        success: function(pathways) {

            // if (dropoffLocation.latitude == 0.0 && dropoffLocation.longitude == 0.0) {
                // In case dropoff location is not set, retrieve all records
                response.success(pathways);
            // } else {

            // }
                    
        },

        error: function(error) {
            response.error(error);
        }

    });

});

///////// Check if pathway exists and retrieve, if any /////////
Parse.Cloud.define("CheckExistingPathway", function(request, response) {
    
    // Get first pathway record and retrieve it.
    var queryPathway = new Parse.Query("DriverPathway");
    queryPathway.equalTo("driver", request.user);
    queryPathway.first({

        useMasterKey: true,

        success: function(pathway) {
            response.success(pathway);    
        },

        error: function(error) {
            response.error(error);
        }

    });
    
});


///////// Delete the existing pathway of requested driver /////////
Parse.Cloud.define("DeletePathway", function(request, response) {
    
    var deleteQuery = new Parse.Query("DriverPathway");
    deleteQuery.equalTo("driver", request.user);
    deleteQuery.find({

        useMasterKey: true,

        success: function(pathways) {
            pathways.forEach(function(pathway) {
                pathway.destroy({useMasterKey: true});
            });

            response.success("success");
        },

        error: function(error) {
            response.error(error);
        }

    });
    
});

// A ride has status.
// Available statuses are requested, inride
// A ride record will be deleted when
//  1 - passenger cancelled request (when the driver not decided Accept/Reject yet)
//  2 - driver rejected
//  3 - driver/passenger cancelled ride (during the riding)
//  4 - driver/passenger finished ride

///////// Request a ride to a selected driver /////////
Parse.Cloud.define("RequestRide", function(request, response) {

    var queryDriver = new Parse.Query("_User");
    queryDriver.get(request.params.driver, {

        useMasterKey: true,

        success: function(driver) {

            var driverFirstName = driver.get("FirstName");

            // Create new ride info record
            var RideInfo = Parse.Object.extend("RideInfo");
            var ride = new RideInfo();

            ride.set("passenger", request.user);
            ride.set("driver", driver);
            ride.set("pickupLatitude", request.params.pickupLocation.latitude);
            ride.set("pickupLongitude", request.params.pickupLocation.longitude);
            ride.set("pickupAddress", request.params.pickupAddress);
            ride.set("dropoffLatitude", request.params.dropoffLocation.latitude);
            ride.set("dropoffLongitude", request.params.dropoffLocation.longitude);
            ride.set("dropoffAddress", request.params.dropoffAddress);
            ride.set("seats", request.params.seats);
            ride.set("price", request.params.price);
            ride.set("status", "requested");
            ride.set("notified", false);

            ride.save(null, {

                useMasterKey: true,

                success: function(saved_ride) {

                    //console.log(saved_ride.id);

                    // After create new ride info, send push to driver
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", driver);
 
                    Parse.Push.send({

                        where: pushQuery,
                        data: {
                            alert: "Hello " + driverFirstName + ", do you want to take this ride?",
                            sound: "default",
                            badge: "Increment",
                            key: "RIDE_REQUEST",
                            "rid": saved_ride.id,
                            "seats": request.params.seats
                        }

                    }, {

                        useMasterKey: true,

                        success: function() {
                            response.success(saved_ride);
                        },

                        error: function(error) {
                            response.error(error);
                        }

                    });

                },

                error: function(error) {
                    response.error(error);
                }

            });

        },

        error: function(error) {
            response.error(error);
        }

    });

});

///////// Retrieve RideInfo object /////////
Parse.Cloud.define("GetRide", function(request, response) {

    var rideQuery = new Parse.Query("RideInfo");
    rideQuery.include("driver");
    rideQuery.include("passenger");
    rideQuery.get(request.params.rideId, {

        useMasterKey: true,

        success: function(ride) {

            response.success(ride);

        },

        error: function(error) {
            response.error(error);
        }

    });

});

///////// Check if ride exists and retrieve, if any /////////
Parse.Cloud.define("CheckExistingRide", function(request, response) {
    
    // First, check if this request comes from driver or from passenger
    request.user.fetch({

        useMasterKey: true,

        success: function(fetched_user) {

            var userMode = fetched_user.get("UserMode");
            //console.log(userMode);

            var rideQuery = new Parse.Query("RideInfo");
            if (userMode == true) {
                rideQuery.equalTo("passenger", request.user);
            } else {
                rideQuery.equalTo("driver", request.user);
            }
            rideQuery.include("passenger");
            rideQuery.include("driver");

            rideQuery.first({

                useMasterKey: true,

                success: function(ride) {
                    response.success(ride);
                },

                error: function(error) {
                    response.error(error);
                }

            });

        },

        error: function(error) {
            response.error(error);
        }

    });
    
});

///////// Accept the ride request by driver /////////
Parse.Cloud.define("AcceptRide", function(request, response) {

    var rideQuery = new Parse.Query("RideInfo");
    rideQuery.include("driver");
    rideQuery.include("passenger");
    rideQuery.get(request.params.rideId, {

        useMasterKey: true,

        success: function(ride) {

            // Change the available seats of driver
            var pathwayQuery = new Parse.Query("DriverPathway");
            pathwayQuery.equalTo("driver", ride.get("driver"));
            pathwayQuery.first({

                useMasterKey: true,

                success: function(pathway) {
                    pathway.set("availableSeats", 0);
                    pathway.save(null, {useMasterKey: true});
                }

            });

            // Change the status to accepted
            ride.set("status", "accepted");
            ride.save(null, {

                useMasterKey: true,

                success: function(saved_ride) {

                    // After changing the status, send push to passenger
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", saved_ride.get("passenger"));
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: saved_ride.get("driver").get("FirstName") + " is on its way to pickup you.",
                            sound: "default",
                            badge: "Increment",
                            key: "RIDE_ACCEPT",
                            rid: saved_ride.id,
                            driverID: saved_ride.get("driver").id
                        }
                    }, {
                        useMasterKey: true,
                        success: function() {
                            response.success(saved_ride);
                        },
                        error: function(error) {
                            response.success(saved_ride);
                        }
                    });

                },

                error: function(error) {
                    response.error(error);
                }

            })

        },

        error: function(error) {
            response.error(error);
        }

    });

});


///////// Delete the ride record /////////
Parse.Cloud.define("DeleteRide", function(request, response) {

    var deleteReason = request.params.reason;

    // First get ride object to delete
    var rideQuery = new Parse.Query("RideInfo");
    rideQuery.include("driver");
    rideQuery.include("passenger");
    rideQuery.get(request.params.rideId, {

        useMasterKey: true,

        success: function(ride) {

            // Get necessary objects
            var driver = ride.get("driver");
            var passenger = ride.get("passenger");
            var rideprice = ride.get("price");
            var ride_id = ride.id;

            // Destroy object in the database
            ride.destroy();

            // And send push per delete reason
            if (deleteReason == 'REQUEST_CANCELED') {
                // Passenger canceled request before driver accepts/rejects
                var pushQuery = new Parse.Query(Parse.Installation);
                pushQuery.equalTo("user", driver);
 
                Parse.Push.send({
                    where: pushQuery,
                    data: {
                        alert: passenger.get("FirstName") + " canceled the ride request.",
                        sound: "default",
                        badge: "Increment",
                        key: "REQUEST_CANCEL",
                        rid: ride_id,
                    }
                }, {
                    useMasterKey: true,
                });
            } else if (deleteReason == 'RIDE_REJECTED') {
                // Driver rejected the request
                var pushQuery = new Parse.Query(Parse.Installation);
                pushQuery.equalTo("user", passenger);
 
                Parse.Push.send({
                    where: pushQuery,
                    data: {
                        alert: driver.get("FirstName") + " rejected the ride request.",
                        sound: "default",
                        badge: "Increment",
                        key: "RIDE_REJECT",
                        rid: ride_id,
                    }
                }, {
                    useMasterKey: true,
                });
            } else {
                if (deleteReason == 'PASSENGER_CANCELED_RIDE') {
                    // Passenger canceled the ride
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", driver);
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: passenger.get("FirstName") + " canceled the ride.",
                            sound: "default",
                            badge: "Increment",
                            key: "RIDE_CANCEL_PASSENGER",
                            rid: ride_id,
                        }
                    }, {
                        useMasterKey: true,
                    });
                } else if (deleteReason == 'DRIVER_CANCELED_RIDE') {
                    //console.log("DRIVER_CANCELED_RIDE");
                    //console.log(passenger);
                    // Driver canceled the ride
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", passenger);
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: driver.get("FirstName") + " canceled the ride.",
                            sound: "default",
                            badge: "Increment",
                            key: "RIDE_CANCEL_DRIVER",
                            rid: ride_id,
                        }
                    }, {
                        useMasterKey: true,
                    });
                } else if (deleteReason == 'DRIVER_ENDED_RIDE') {
                    // Ride ended
                    // Once ride is ended, adjust balances
                    var driver_bal = driver.get("Balance");
                    var passenger_bal = passenger.get("Balance");
                    driver_bal = driver_bal + rideprice;
                    passenger_bal = passenger_bal - rideprice;
                    driver.set("Balance", driver_bal);
                    passenger.set("Balance", passenger_bal);
                    // Once ride is ended, adjust ride count

                    driver.save(null, {useMasterKey: true});
                    passenger.save(null, {useMasterKey: true});

                    // Send push notification
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", passenger);
 
                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: driver.get("FirstName") + " ended the ride.",
                            sound: "default",
                            badge: "Increment",
                            key: "RIDE_END_DRIVER",
                            rid: ride_id,
                        }
                    }, {
                        useMasterKey: true,
                    });
                }

                // Change the available seats of driver
                var pathwayQuery = new Parse.Query("DriverPathway");
                pathwayQuery.equalTo("driver", driver);
                pathwayQuery.first({

                    useMasterKey: true,

                    success: function(pathway) {
                        pathway.set("availableSeats", pathway.get("numberOfSeats"));
                        pathway.save(null, {useMasterKey: true});
                    }

                });
            }

            response.success(ride_id);

        },

        error: function(error) {
            response.error(error);
        }

    });

});

///////// Rate to the Passenger or Driver //////////
Parse.Cloud.define("CreateRating", function(request, response) {

    var isDriver = request.params.isDriver;
    var pricePerSeat = request.params.pricePerSeat;
    var seats = request.params.seats;
    var usedBalance = pricePerSeat * seats * 100;
    console.log("used balance ============================ ", usedBalance);

    var queryDriver = new Parse.Query("_User");
    queryDriver.get(request.params.to, {

        useMasterKey: true,

        success: function(toUser) {

            // Create new Rating.
            var UserRating = Parse.Object.extend("Rating");
            var rating = new UserRating();

            rating.set("from", request.user);
            rating.set("to", toUser);
            rating.set("isDriver", isDriver);
            rating.set("rating", request.params["rating"]);
            
            rating.save(null, {

                useMasterKey: true,

                success: function() {
                    
                    // Update user rating info on User Class
                    var ratingQuery = new Parse.Query("Rating");
                    ratingQuery.equalTo("to", toUser);
                    ratingQuery.equalTo("isDriver", isDriver);
                    ratingQuery.find({

                        useMasterKey: true,

                        success: function(results) {
                            
                            var ratingValue = 0;
                            for (var i = 0; i < results.length; i++) {
                                ratingValue = ratingValue + results[i].get("rating");
                            }
                            var totalRating = ratingValue / results.length;

                            // Update user Balance info on User Class
                            var currentBalance = toUser.get("Balance");
                            var totalBalance;

                            if (isDriver == false) {
                                totalBalance = currentBalance - usedBalance;
                                toUser.set("passengerRating", totalRating);
                                toUser.set("passengerRideCount", results.length);
                                console.log("passenger currentBalance =============", currentBalance);
                                console.log("passenger totalBalance =============", totalBalance);
                            } else {
                                totalBalance = currentBalance + usedBalance;
                                toUser.set("driverRating", totalRating);
                                toUser.set("driverRideCount", results.length);
                                console.log("driver currentBalance =============", currentBalance);
                                console.log("driver totalBalance =============", totalBalance);
                            }

                            toUser.set("Balance", totalBalance);

                            toUser.save(null, {useMasterKey: true});

                            response.success("success");
                        },

                        error: function(error) {
                            response.error(error);
                        }
                    });
                },

                error: function(error) {
                    response.error(error);
                }
            });
        },

        error: function(error) {
            response.error(error);
        }
    });

});


/////// Create board message ///////
Parse.Cloud.define("CreateBoardMessage", function(request, response) {

    // Create new board message
    var BoardMessage = Parse.Object.extend("BoardMessage");
    var rideMessage = new BoardMessage();

    rideMessage.set("author", request.user);
    rideMessage.set("driverMessage", request.params["driverMessage"]);
    rideMessage.set("status", request.params["status"]);
    rideMessage.set("seats", request.params["seats"]);
    rideMessage.set("pricePerSeat", request.params["pricePerSeat"]);
    rideMessage.set("pickupLat", request.params["pickupLat"]);
    rideMessage.set("pickupLong", request.params["pickupLong"]);
    rideMessage.set("dropoffLat", request.params["dropoffLat"]);
    rideMessage.set("dropoffLong", request.params["dropoffLong"]);
    rideMessage.set("pickupAddress", request.params["pickupAddress"]);
    rideMessage.set("dropoffAddress", request.params["dropoffAddress"]);
    rideMessage.set("title", request.params["title"]);
    rideMessage.set("desc", request.params["desc"]);
    rideMessage.set("city", request.params["city"]);
    rideMessage.set("date", request.params["date"]);
    rideMessage.set("femaleOnly", request.params["femaleOnly"]);

    rideMessage.save(null, {

        useMasterKey: true,

        success: function(newMessage) {
            
            // Send push notification
            var pushQuery = new Parse.Query(Parse.Installation);
            pushQuery.notEqualTo("user", request.user);

            Parse.Push.send({
                where: pushQuery,
                data: {
                    alert: request.user.get("FirstName") + " created a new message.",
                    sound: "default",
                    badge: "Increment",
                    key: "CREATE_BOARDMESSAGE",
                    rid: newMessage.id,
                }
            }, {
                useMasterKey: true,
            });
     
        },

        error: function(error) {
            response.error(error);
        }
    });

    response.success("success");

});


/////// Get user review ///////
Parse.Cloud.define("GetUserReview", function(request, response) {

    var queryDriver = new Parse.Query("_User");
    queryDriver.get(request.params["to"], {

        useMasterKey: true,

        success: function(toUser) {

            var queryRating = new Parse.Query("Rating");
            queryRating.equalTo("to", toUser);
            queryRating.equalTo("isDriver", request.params.isDriver);
            queryRating.include("from");
            queryRating.include("createdAt");
            queryRating.descending("createdAt");
            queryRating.find({
                
                useMasterKey: true,

                success: function(review) {
                    
                    response.success(review);
                },

                error: function(error) {
                    response.error(error);
                }
            });
        },

        error: function(error) {
            response.error(error);
        }
    });
});


////// Submit price to the board message //////////
Parse.Cloud.define("RequestToBoardMessage", function(request, response) {

    var reason = request.params.reason;
    var isJoin = request.params.isJoin;

    var boardMessageQuery = new Parse.Query("BoardMessage");
    boardMessageQuery.include("author");
    boardMessageQuery.equalTo("objectId", request.params.boardMessageId);
    boardMessageQuery.find({

        useMasterKey: true,

        success: function(boardMessages) {

            // update board message status when passenger/driver join/submitt
            var boardMessage = boardMessages[0];
            boardMessage.save(null, {useMasterKey: true});

            var toUser = boardMessage.get("author");

            // create new request message record
            var CreateRequestMessage = Parse.Object.extend("RequestMessage");
            var requestMessage = new CreateRequestMessage();

            requestMessage.set("from", request.user);
            requestMessage.set("to", toUser);
            requestMessage.set("rideMessage", boardMessage);
            requestMessage.set("price", request.params.price);
            requestMessage.set("seats", request.params.seats);
            requestMessage.set("status", reason);

            requestMessage.save(null, {

                useMasterKey: true,

                success: function(saved_requestMessage) {
                    
                    var driver = request.user;
                    var requestMessage_id = saved_requestMessage.id;
                    var pushMessage;
                    if (isJoin) {
                        pushMessage = " joined your board message."
                    } else {
                        pushMessage = " priced your board message.";
                    }

                    // Send push notification
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", toUser);

                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: driver.get("FirstName") + pushMessage,
                            sound: "default",
                            badge: "Increment",
                            key: "REQUEST_PRICE_BOARDMESSAGE",
                            rid: requestMessage_id,
                        }
                    }, {
                        useMasterKey: true,
                    });

                    response.success(requestMessage_id);
                },

                error: function(error) {
                    response.error(error);
                }
            });
        },

        error: function(error) {

        }
    });
});


////// Get all request message ///////
Parse.Cloud.define("GetAllMessages", function(request, response) {

    var requestType = request.params.requestType;

    if (requestType == 'all') {
        var query1 = new Parse.Query("RequestMessage");
        var query2 = new Parse.Query("RequestMessage");
        var query3 = new Parse.Query("RequestMessage");

        query1.equalTo("status", "join");
        query1.equalTo("from", request.user);
        query2.equalTo("status", "request");
        query2.equalTo("from", request.user);
        query3.equalTo("status", "accept");
        query3.equalTo("from", request.user);

        var allRequestQuery = Parse.Query.or(query1, query2, query3);
        allRequestQuery.include("rideMessage");
        allRequestQuery.find({

            useMasterKey: true,

            success: function(allRequestMessages) {

                var boardIds = [];
                allRequestMessages.forEach(function(requestMessage) {

                    boardIds.push(requestMessage.get("rideMessage").id);

                });

                var boardMessageQuery = new Parse.Query("BoardMessage");
                boardMessageQuery.include("author");
                boardMessageQuery.notContainedIn("objectId", boardIds);
                boardMessageQuery.notEqualTo("author", request.user);
                boardMessageQuery.descending("createdAt");
                boardMessageQuery.find({

                    useMasterKey: true,

                    success: function(boardMessages) {
                        //console.log(boardMessages.length);
                        response.success(boardMessages);
                    },
                    error: function(error) {
                        response.error(error);
                    }
                });
            },
            error: function(error) {
                response.error(error);
            }
        }); 

    } else {
        var query1 = new Parse.Query("RequestMessage");
        var query2 = new Parse.Query("RequestMessage");
        var query3 = new Parse.Query("RequestMessage");
        var query4 = new Parse.Query("RequestMessage");

        var allMessageQuery;

        if (requestType == 'request') {
            // Get all requested messages
            var arrAllRequestMessage = [];

            query1.equalTo("status", "join");
            query1.equalTo("to", request.user);
            query2.equalTo("status", "request");
            query2.equalTo("from", request.user);

            query3.equalTo("status", "join");
            query3.equalTo("from", request.user);
            query4.equalTo("status", "request");
            query4.equalTo("to", request.user);

            allMessageQuery = Parse.Query.or(query1, query2, query3, query4);
            allMessageQuery.include("from");
            allMessageQuery.include("to");
            allMessageQuery.include("rideMessage");
            allMessageQuery.descending("createdAt");
            allMessageQuery.find({

                useMasterKey: true,

                success: function(requestMessage) {

                    arrAllRequestMessage.push(requestMessage);

                    // board message of requested user
                    var boardMessageQuery = new Parse.Query("BoardMessage");
                    boardMessageQuery.equalTo("author", request.user);
                    boardMessageQuery.include("author");
                    boardMessageQuery.find({

                        useMasterKey: true,

                        success: function(boardMessages) {

                            arrAllRequestMessage.push(boardMessages);
                            response.success(arrAllRequestMessage);

                        },
                        error: function(error) {
                            response.error(error);
                        }
                    });
                },
                error: function(error) {
                    response.error(error);
                }
            });

        } else {
            // Get all accepted messages
            var query1 = new Parse.Query("RequestMessage");
            var query2 = new Parse.Query("RequestMessage");
            query1.equalTo("status", "accept");
            query1.equalTo("to", request.user);
            query2.equalTo("status", "accept");
            query2.equalTo("from", request.user);

            allMessageQuery = Parse.Query.or(query1, query2);
            allMessageQuery.include("from");
            allMessageQuery.include("to");
            allMessageQuery.include("rideMessage");
            allMessageQuery.descending("createdAt");
            allMessageQuery.find({

                useMasterKey: true,

                success: function(requestMessage) {

                    response.success(requestMessage);

                },
                error: function(error) {
                    response.error(error);
                }
            }); 
        }
    }
});


/////// Delete ride request message /////////
Parse.Cloud.define("DeleteRideMessage", function(request, response) {

    var rideObjId = request.params.deleteMessageObjId;
    var deleteReason = request.params.reason;

    if (deleteReason == 'DELETE_RIDE_MESSAGE') {

        var boardMessageQuery = new Parse.Query("BoardMessage");
        boardMessageQuery.get(rideObjId, {

            useMasterKey: true,

            success: function(boardMessage) {

                var requestMessageQuery = new Parse.Query("RequestMessage");
                requestMessageQuery.equalTo("rideMessage", boardMessage);
                requestMessageQuery.include("from");
                requestMessageQuery.include("to");
                requestMessageQuery.find({

                    useMasterKey: true,

                    success: function(requestMessages) {
                        //console.log("==============//==============", requestMessages.length);
                        requestMessages.forEach(function(requestMessage) {

                            var toUser = requestMessage.get("to");
                            var fromUser = requestMessage.get("from");
                            //console.log("to user ==========", toUser.id);

                            // Send push notification
                            var pushQuery = new Parse.Query(Parse.Installation);
                            pushQuery.equalTo("user", fromUser);

                            Parse.Push.send({
                                where: pushQuery,
                                data: {
                                    alert: toUser.get("FirstName") + " deleted board message. So your request was declined.",
                                    sound: "default",
                                    badge: "Increment",
                                    key: "AUTO_DECLINE_BOARDMESSAGE",
                                }
                            }, {
                                useMasterKey: true,
                            });
                            // delete request message in Database
                            requestMessage.destroy({useMasterKey: true});
                        });
                        response.success("success");
                    },
                    error: function(error) {
                        response.error(error);
                    }
                });
                // delete board message in Database
                boardMessage.destroy({useMasterKey: true});
            },

            error: function(error) {
                response.error(error);
            }
        });

    } else {

        var requestRideQuery = new Parse.Query("RequestMessage");
        requestRideQuery.include("from");
        requestRideQuery.include("to");
        requestRideQuery.include("rideMessage");
        requestRideQuery.equalTo("objectId", rideObjId);
        requestRideQuery.get(rideObjId, {

            useMasterKey: true,

            success: function(requestMessage) {

                // Get necessary objects
                var from = requestMessage.get("from");
                var to = requestMessage.get("to");
                var rideMessage = requestMessage.get("rideMessage");
                var author = rideMessage.get("author");
                var isRideMessage = rideMessage.get("driverMessage");

                var pushMessage;

                if (deleteReason == 'DECLINE_RIDE_MESSAGE') {

                    pushMessage = " declined your ride request.";

                    var boardMessageQuery = new Parse.Query("BoardMessage");
                    boardMessageQuery.get(rideMessage.id, {

                        useMasterKey: true,

                        success: function(boardMessage) {
                            //console.log("baord message is =============   ", boardMessage);
                            boardMessage.set("status", "");
                            boardMessage.save(null, {useMasterKey: true});
                        },

                        error: function(error) {
                            response.error(error);
                        }
                    });

                    // Send push notification
                    var userName;
                    var pushQuery = new Parse.Query(Parse.Installation);

                    if (author.id == request.user.id) {

                        if (isRideMessage) {
                            pushQuery.equalTo("user", from);
                            userName = to.get("FirstName");
                        } else {
                            pushQuery.equalTo("user", from);
                            userName = to.get("FirstName")
                        }
                    } else {
                        if (isRideMessage) {
                            pushQuery.equalTo("user", to);
                            userName = from.get("FirstName");
                        } else {
                            pushQuery.equalTo("user", to);
                            userName = from.get("FirstName");
                        }
                    }

                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: userName + pushMessage,
                            sound: "default",
                            badge: "Increment",
                            key: "DELETE_RIDE_MESSAGE",
                            rid: rideObjId,
                        }
                    }, {
                        useMasterKey: true,
                    });
                }
                else if (deleteReason == 'CANCEL_RIDE_MESSAGE') {
                    pushMessage = " canceled the ride message.";

                    var boardMessageQuery = new Parse.Query("BoardMessage");
                    boardMessageQuery.get(rideMessage.id, {

                        useMasterKey: true,

                        success: function(boardMessage) {

                            boardMessage.set("status", "");
                            boardMessage.save(null, {useMasterKey: true});

                            // update user cancel rider info
                            request.user.fetch({

                                useMasterKey: true,

                                success: function(user) {
                                    var cancelRideCount;

                                    if (author.id == request.user.id) {
                                        if (isRideMessage) {
                                            cancelRideCount = user.get("driverCancelRideCount");
                                            user.set("driverCancelRideCount", cancelRideCount + 1);
                                        } else {
                                            cancelRideCount = user.get("passengerCancelRideCount");
                                            user.set("passengerCancelRideCount", cancelRideCount + 1);
                                        }
                                    } else {
                                        if (isRideMessage) {
                                            cancelRideCount = user.get("passengerCancelRideCount");
                                            user.set("passengerCancelRideCount", cancelRideCount + 1);
                                        } else {
                                            cancelRideCount = user.get("driverCancelRideCount");
                                            user.set("driverCancelRideCount", cancelRideCount + 1);
                                        }
                                    }
                                    user.save(null, {useMasterKey: true});
                                },

                                error: function(error) {
                                    response.error(error);
                                }
                            });
                        },

                        error: function(error) {
                            response.error(error);
                        }
                    });

                    // Send push notification
                    var userName;
                    var pushQuery = new Parse.Query(Parse.Installation);
                    if (author.id == request.user.id) {
                        if (isRideMessage) {
                            pushQuery.equalTo("user", from);
                            userName = to.get("FirstName");
                        } else {
                            pushQuery.equalTo("user", from);
                            userName = to.get("FirstName")
                        }
                    } else {
                        if (isRideMessage) {
                            pushQuery.equalTo("user", to);
                            userName = from.get("FirstName");
                        } else {
                            pushQuery.equalTo("user", to);
                            userName = from.get("FirstName");
                        }
                    }

                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: userName + pushMessage,
                            sound: "default",
                            badge: "Increment",
                            key: "DELETE_RIDE_MESSAGE",
                            rid: rideObjId,
                        }
                    }, {
                        useMasterKey: true,
                    });
                }
                else if (deleteReason == 'END_RIDE_MESSAGE') {

                    pushMessage = " ended the ride message.";

                    var boardMessageQuery = new Parse.Query("BoardMessage");
                    boardMessageQuery.get(rideMessage.id, {

                        useMasterKey: true,

                        success: function(boardMessage) {

                            boardMessage.destroy({useMasterKey: true});

                        },

                        error: function(error) {
                            response.error(error);
                        }
                    });
                }
                
                // Destroy ride object in the database
                requestMessage.destroy({useMasterKey: true});
                
                response.success("success");
            },

            error: function(error) {
                response.error(error);
            }
        });
    }
});

Parse.Cloud.job("endRideMessage", function(request, status) {

    var intervalOfTime = 60*1000;  // 1 hour in milliseconds

    var date = new Date();
    var timeNow = date.getTime();
    var timeThen = timeNow - intervalOfTime;
      // Limit date
    var queryDate = new Date();
    queryDate.setTime(timeThen);

    var requestRideQuery = new Parse.Query("RequestMessage");
    requestRideQuery.include("from");
    requestRideQuery.include("to");
    requestRideQuery.include("rideMessage");
    requestRideQuery.equalTo("status", "accept");
    requestRideQuery.lessThan("updatedAt", queryDate);
    requestRideQuery.find({

        useMasterKey: true,

        success: function(allAcceptedMessages) {

            allAcceptedMessages.forEach(function(requestMessage) {

                // Get necessary objects
                var from = requestMessage.get("from");
                var to = requestMessage.get("to");
                var rideMessage = requestMessage.get("rideMessage");
                console.log("updatedAt ==================", requestMessage.id);
                requestMessage.set("updatedAt", date);
                requestMessage.save(null, {useMasterKey: true});

                // Send push notification
                var pushQuery1 = new Parse.Query(Parse.Installation);
                var pushQuery2 = new Parse.Query(Parse.Installation);
                pushQuery1.equalTo("user", to);
                pushQuery2.equalTo("user", from);

                var pushQuery = Parse.Query.or(pushQuery1, pushQuery2);
                Parse.Push.send({
                    where: pushQuery,
                    data: {
                        alert: "Your journey has been ended. You need to give rating.",
                        sound: "default",
                        badge: "Increment",
                        key: "END_RIDE_MESSAGE",
                        rid: requestMessage.id,
                    }
                }, {
                    useMasterKey: true,
                });

            });
        },

        error: function(error) {

        }
    });
});

/////// Accept the Ride Message /////////
Parse.Cloud.define("AcceptRideMessage", function(request, response) {

    var reason = request.params.reason;

    var acceptRideQuery = new Parse.Query("RequestMessage");
    acceptRideQuery.include("from");
    acceptRideQuery.include("to");
    acceptRideQuery.include("rideMessage");
    acceptRideQuery.equalTo("objectId", request.params.rideObjId);
    acceptRideQuery.find({

        useMasterKey: true,

        success: function(requestMessages) {

            var acceptMessage = requestMessages[0];
            var rideMessage = acceptMessage.get("rideMessage");
            var toUser = acceptMessage.get("from");

            // update board message status
            rideMessage.set("status", reason);
            rideMessage.save(null, {useMasterKey: true});
            // update request message status
            acceptMessage.set("status", reason);
            acceptMessage.save(null, {

                useMasterKey: true,

                success: function(saved_requestMessage) {
                    
                    var driver = request.user;
                    var acceptedMessage_id = saved_requestMessage.id;

                    // Send push notification
                    var pushQuery = new Parse.Query(Parse.Installation);
                    pushQuery.equalTo("user", toUser);

                    Parse.Push.send({
                        where: pushQuery,
                        data: {
                            alert: driver.get("FirstName") + " accepted your request.",
                            sound: "default",
                            badge: "Increment",
                            key: "ACCEPT_BOARDMESSAGE",
                            rid: acceptedMessage_id,
                        }
                    }, {
                        useMasterKey: true,
                    });

                    response.success(acceptedMessage_id);
                },

                error: function(error) {
                    response.error(error);
                }
            });

            // decline ride message
            var declineRideQuery = new Parse.Query("RequestMessage");
            declineRideQuery.include("from");
            declineRideQuery.include("to");
            declineRideQuery.equalTo("rideMessage", rideMessage);
            declineRideQuery.notEqualTo("objectId", request.params.rideObjId);
            declineRideQuery.find({

                useMasterKey:true,

                success: function(allRequestMessages) {

                    allRequestMessages.forEach(function(requestMessage) {

                        var toUser = requestMessage.get("to");
                        var fromUser = requestMessage.get("from");
                        //console.log("decline request message =================  ", requestMessage);

                        // Send push notification
                        var pushQuery = new Parse.Query(Parse.Installation);
                        pushQuery.equalTo("user", fromUser);

                        Parse.Push.send({
                            where: pushQuery,
                            data: {
                                alert: toUser.get("FirstName") + " selected another person.",
                                sound: "default",
                                badge: "Increment",
                                key: "AUTO_DECLINE_BOARDMESSAGE",
                            }
                        }, {
                            useMasterKey: true,
                        });
                        
                        requestMessage.destroy({useMasterKey: true});
                    });
                },

                error: function(error) {

                }
            });
        },

        error: function(error) {

        }
    });
});


