({
    //To verify the lead file size
    sendFileAsAttachment : function(component) {
        var _this = this;
        var recpList = '';
        var inputCmp = component.find('emailRecipients')
        var emailRecp = inputCmp.get("v.value");
        if(!$A.util.isEmpty(emailRecp)) {
            var emails = '';
            var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
            if(!emailRecp.includes(";") ) {
                if(!re.test(emailRecp.trim())) {
                    _this.userNotification('error','Failure!','Invalid email address found');
                } else {
                    recpList = emailRecp;
                }
                
            } else {
                emails = emailRecp.split(';');
                for (var i = 0; i < emails.length; i++) {
                    if(!$A.util.isEmpty(emails[i].trim())) {
                        if(!re.test(emails[i].trim())) {
                            _this.userNotification('error','Failure!','Invalid email address found');
                        } else {
                            recpList += emails[i].trim()+';';
                        } 
                    }
                }
            }
            if(!$A.util.isEmpty(recpList)) {
                _this.sendAttachment(component, component.get("v.recordId"), recpList);
            }
        } else {
            _this.userNotification('error','Failure!','Email cannot be left as blank');
        }
        
        
    },
    
    //To display all error info for user.
    sendAttachment : function(component, recId, recpEmails) {
        var _this = this;
        var actionName = "c.sendFilesAsAttachmentToUsers"; 
        var params = {
            "leadId": recId,
            "emailRecp": recpEmails
        };
        _this.callAction(component, actionName, params, function(response){
            _this.userNotification("success", "Success!", "Your lead has been sent.");
            _this.closeQuickAction();
        });
    },
    
    //To display all error info for user.
    userNotification : function(infoVariant, infoHeader, infoMessage) {
        var _this = this;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: infoHeader,
            type: infoVariant,
            message: infoMessage,
            mode: 'dismissible',
            duration : '5000'
        });
        toastEvent.fire();
    },
    
    //To close the quick action popup
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    
    //Used to get required Growth Opportunity info from the server
    callAction: function(component, actionName, params, callback){  
        var _this = this;
        var action = component.get(actionName);
        action.setParams(params);
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var ctrlResult = response.getReturnValue();
                if(!ctrlResult.hasError) {
                    callback(ctrlResult);
                } else {
                    _this.userNotification('error','Failure!',ctrlResult.errorMessage);
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                _this.userNotification('error','Failure!','Failed to process data. Please contact System Administrator');
            }
        });
        $A.enqueueAction(action);
    }
})