({
    //Used to call the helper method which is used to check some pre conditions
    sendEmail : function(component, event, helper) {
        helper.sendFileAsAttachment(component);
    },
    //To close the quick action popup
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})