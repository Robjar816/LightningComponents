({
    closeModel: function(component, event, helper) {
        component.set("v.showRecordForm", false);
    },
    
    init: function (component, event, helper) {
        helper.loadModel(component, event);
    },
    
    getText : function (component, event, helper) {
        helper.getTemplateBody(component, event);
    }, 
    
    handleTask: function(component, event, helper) {
        helper.getPicklistValues(component, event);
        
    },
    handleTaskCreate : function(component, event, helper) {
        helper.saveTask(component, event);
    },
    
    handleNote: function(component, event, helper) {
        helper.createNote(component, event);
    },
    
    handleChange : function(component, event, helper) {
        helper.getDependentPicklist(component, event);
    },
    
    handleSubmit : function(component, event, helper) {
        helper.saveTask(component, event);
    },
    
    handleAssignTo : function(component, event, helper) {
        helper.dispalyAssignTo(component, event);
    },
    
    handleEvent : function(component, event, helper) {
        helper.populateTemplate(component, event);
    },
    
    handleSelectTemplate : function(component, event, helper) {
        component.set("v.callChildComp", true);
    }
});