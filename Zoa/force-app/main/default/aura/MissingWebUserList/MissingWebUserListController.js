/**
 * Created by jesus.cantero on 13/05/2021.
 */

({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Id', fieldName: 'id', type: 'text'},
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'UserName', fieldName: 'userName', type: 'text'},
            {label: 'Email', fieldName: 'email', type: 'email'},
            {label: 'Company Name', fieldName: 'company', type: 'text'}
        ]);

        //calling the controller method to perform the REST call and populating the dataTable, showing success or error message depending by the result
        var action = cmp.get("c.getServiceResponse");	
		action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS"){

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "User records correctly retrieved from external service!"
            });
            toastEvent.fire();

            cmp.set("v.data", response.getReturnValue()); 
        
   		} else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Something went wrong with the call to the external service, please contact support team. Error message: \"" + response.getError()[0].message+"\""
            });
            toastEvent.fire();
        }
            
		});
		$A.enqueueAction(action);
    },

    

    handleClick: function(cmp,event,helper){ 
        //calling the "Web_User__c" creator method within apex controller
        var action = cmp.get("c.webUserCreator");	
        action.setParams({ webUsers : JSON.stringify(cmp.get("v.data")) });
		action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS"){

            //if the response contains "excludedUsers" display a warning message with a list of excluded "Web_Users__c" Ids
            if(response.getReturnValue().excludedUsers.length>0){

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning",
                    "type": "warning",
                    "message": "These users: \""+ response.getReturnValue().excludedUsers +"\" cannot be inserted because they are duplicates"
                });
                toastEvent.fire();
            }
        	
            //if the response contains "insertedUsersList" display a success message with a list of inserted "Web_Users__c" Ids
            if(response.getReturnValue().insertedUsersList.length > 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Following users: \""+ response.getReturnValue().insertedUsersList+ "\" correctly inserted!"
                });
                toastEvent.fire();
            }


        
   		} else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message": "Something went wrong with the call to the external service, please contact support team. Error message: \"" + response.getError()[0].message+"\""
            });
            toastEvent.fire();
        }
            
		});
		$A.enqueueAction(action);
    }
});