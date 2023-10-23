({

    doInit: function (component, event, helper) {
        //component.find("overlayLib").notifyClose();
        if (navigator.geoLocation) {
            console.log("capability is there");
        } else {
            console.log("No Capability");
        }
        navigator.geolocation.getCurrentPosition(function (position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude", latit);
            component.set("v.longitude", longit);
            helper.submit(component, event, helper);
        }, function () {
           helper.showErrorToast(component, event, helper, 'Warning!', 'Please Grant Location Access!');
        }, {
            maximumAge: 600000
        });


        /*   var lat = component.get("v.latitude");
           var lng = component.get("v.longitude");
           var recordId = component.get('v.recordId');
           var status = component.get("v.UserStartTime");
           var action = component.get('c.updatelocation');
           action.setParams({
               recId: recordId,
               lat: lat,
               lng: lng,
               status: status
           });

           action.setCallback(this, function (response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   dismissActionPanel.fire();
                   var resultsToast = $A.get("e.force:showToast");
                   resultsToast.setParams({
                       "title": "",
                       "message": "Record Updated Successfully",
                       "type": 'success'
                   });
                   resultsToast.fire();
                   $A.get("e.force:refreshView").fire();
               } else {
                   console.log("Failed with state: " + state);
               }
           });
           $A.enqueueAction(action); */
    },
    submit: function (component, event, helper) {
        if (component.find('starttime').get('v.value') != undefined) {
            var lat = component.get("v.latitude");
            var lng = component.get("v.longitude");
            var recordId = component.get('v.recordId');
            var strttime = component.find('starttime').get('v.value');
            var status = component.get("v.UserStartTime");

            var action = component.get('c.updatelocation');
            action.setParams({
                recId: recordId,
                lat: lat,
                lng: lng,
                userDatatime: strttime,
                status: status
            });

            action.setCallback(this, function (response) {

                var state = response.getState();

                if (state === "SUCCESS") {

                    var dismissActionPanel = $A.get("e.force:closeQuickAction");

                    dismissActionPanel.fire();

                    var resultsToast = $A.get("e.force:showToast");

                    resultsToast.setParams({

                        "title": "",

                        "message": "record update sucessfully",

                        "type": 'success'

                    });
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                } else {

                    console.log("Failed with state: " + state);

                }

            });

            $A.enqueueAction(action);
        } else {
            var resultToast = $A.get("e.force:showToast");

            resultToast.setParams({

                "title": "",

                "message": "Please Select Start Date and Time",

                "type": 'Error'

            });
            resultToast.fire();

        }
    },


    close: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        $A.get("e.force:refreshView").fire();
    },

})