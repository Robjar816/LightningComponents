({
    doInit: function (component, event, helper) {
        console.log('SendTo value: ' + component.get("v.sendTo"));
        component.set("v.showUser", true);
        component.set("v.sendTo", 'User');
        component.set("v.SendToUserId", component.find("sendToUserValue").get("v.value"));

        var caseId = component.get("v.recordId");
        var action = component.get("c.getCaseRec");
        action.setParams({
            "caseId": caseId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null && response.getReturnValue() != "" && response.getReturnValue() != undefined) {
                    component.set("v.email", response.getReturnValue().Email);
                }
            }
        });        
        
        helper.getFolders(component, event);
        helper.getFromAddresses(component, event);
        $A.enqueueAction(action);

    },

    sendMail: function (component, event, helper) {
		//Check the send to type selected and assign the value
        if (component.get("v.sendTo") === 'User') {            
           var sendToUserId = component.find("sendToUserValue").get("v.value"); 
           var sendToContactId = '';
        } else if (component.get("v.sendTo") === 'Contact'){
            console.log('Send To Value: ' + component.get("v.sendTo"));
            var sendToContactId = component.find("sendToContactValue").get("v.value");
            var sendToUserId = '';
        }else {
			var sendToContactId = '';
            var sendToUserId = '';
        }

        var subject = component.get("v.subject");
        var body = component.get("v.emailbody");
        var caseId = component.get("v.recordId");
        var sendTo = component.get("v.sendTo");
        var cc = component.get("v.ccEmail");
        var attachments = component.get("v.attachmentIds");
        var from = component.get("v.fromAddress");
        
        // check if Email field is Empty or not contains @ so display a alert message 
        // otherwise call call and pass the fields value to helper method    
        if ($A.util.isEmpty(sendToContactId) && $A.util.isEmpty(sendToUserId)) {
            alert('Please Enter valid Email Address');
        } else if ($A.util.isEmpty(subject)) {
            alert('Please Enter a Subject');
        } else if ($A.util.isEmpty(body)) {
            alert('Please Enter a some text into the Email Body');
        }else {
            helper.sendHelper(component, sendTo, sendToContactId, sendToUserId, subject, body, caseId, cc, attachments, from);
        }
    },

    // when user click on the close buttton on message popup ,
    // hide the Message box by set the mailStatus attribute to false
    // and clear all values of input fields.   
    closeMessage: function (component, event, helper) {
        component.set("v.mailStatus", false);
        component.set("v.errorStatus", false);
        component.set("v.email", null);
        component.set("v.subject", null);
        component.set("v.emailbody", null);
        component.set("v.ccEmail", null);
        component.set("v.attachmentIds", null);
        component.set("v.numberAttachments", '0');
        component.set("v.emailfolderVSTemplateList", null);
        component.set("v.emailTemplateList", null);
        component.set("v.fromAddress", null);
        helper.getFolders(component, event);
		helper.getFromAddresses(component, event);
        $A.get('e.force:refreshView').fire();
    },

    onSelectEmailFolder: function (component, event, helper) {
        var folderId = event.target.value;
        helper.getTemplates(component, event, folderId);         
    },

    onSelectEmailTemplate: function (component, event, helper) {
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.templateIDs", emailTempId);
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                    emailbody = element.emailbody;
                    emailSubject = element.emailSubject;
                }
            });
        }
        component.set("v.emailbody", emailbody);
        component.set("v.subject", emailSubject);

    },

    closeModal: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    openmodal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    handleSendTo : function(component, event) {
        var sendTo = component.get("v.sendTo");
        console.log("sendTo = " + sendTo);
        if(sendTo == "User") {
            component.set("v.showUser", true);
            component.set("v.showContact", false);
        }else if(sendTo == "Contact"){
            component.set("v.showUser", false);
            component.set("v.showContact", true);
        }else {
            component.set("v.showUser", false);
            component.set("v.showQueue", false);
        }
    },
    
    handleUploadFinished : function(component, event) {
        var uploadedFiles = event.getParam("files");
        var fileIds = [];
        var fileNames = [];
        uploadedFiles.forEach(file => fileIds.push(file.documentId));
        uploadedFiles.forEach(file => console.log('File Name: ' + file.documentId));
        component.set("v.attachmentIds", fileIds);
        component.set("v.numberAttachments", fileIds.length);
        console.log('Names: ' + component.get("v.numberAttachments"));
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
   },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.spinner", false);
    }
   
});