({
    sendHelper: function (component, sendTo, sendToContactId, sendToUserId, subject, body, caseId, cc, attachments, fromAddress) {
		component.set("v.spinner", true);
        // call the server side controller method 	
        console.log('sendHelper');
        var action = component.get("c.sendMailMethod");
        var templateId = component.get("v.templateIDs");
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'sendTo': sendTo,
            'sendToContactId': sendToContactId,
            'sendToUserId': sendToUserId,
            'mSubject': subject,
            'mbody': body,
            'caseId': caseId,
            'folderId': component.get("v.folderId1"),
            'templateId': component.get("v.templateIDs"),
            'ccEmail': cc,
            'attachments': attachments,
            'fromAddress': fromAddress
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('State = SUCCESS');
                component.set("v.spinner", false);
                var storeResponse = response.getReturnValue();             
                // if state of server response is comes "SUCCESS",
                // display the success message box by set mailStatus attribute to true
                if(storeResponse === '1'){
					component.set("v.mailStatus", true);
                    component.set("v.errorStatus", false); 
                } else { 
                    component.set("v.errorMessage", storeResponse);
					component.set("v.errorStatus", true);
					component.set("v.mailStatus", false);                    
                }
                
            } else {                
                console.log('Not a SUCCESS: ' + state);
                component.set("v.spinner", false);
                component.set("v.errorMessage", state + ': ' + storeResponse);
                component.set("v.mailStatus", false);
                component.set("v.errorStatus", true);
            }

        });
        $A.enqueueAction(action);
    },
    
    getFolders : function(component, event) {
        var action = component.get("c.getTemplateFolders");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    //console.log('Folders: ' + response.getReturnValue().length);
                    component.set("v.emailfolderVSTemplateList", response.getReturnValue());
                }else {
                    console.log('State not SUCCESS');
                }
            }
        });
        $A.enqueueAction(action); 
    },
    
    getTemplates : function(component, event, folderId) {
        var action = component.get("c.getTemplates");
        action.setParams({
            "folderId": folderId
        });     
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    component.set("v.emailTemplateList", response.getReturnValue());
                }else {
                    console.log('Templates: ' + response.getReturnValue().length);
                }
            }
        });
        $A.enqueueAction(action);          
    },
    
    getFromAddresses : function(component, event) {
        var action = component.get("c.getFromAddresses");
   
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    var addresses = response.getReturnValue();
                    component.set("v.fromAddresses", addresses);
                	console.log('From Address Selected on load: ' + addresses[0]);                    
                    component.set("v.fromAddress", addresses[0]);
                    console.log('From Addresses: ' +  component.get("v.fromAddresses"));
                }
            }else {
                console.log('Error getting from addresses');
            }
        });
        $A.enqueueAction(action); 
    }    
})