({
    init:function(component, event, helper){
        var staticLabel = $A.get("$Label.c.casefields");
        
        component.set("v.fields", staticLabel.split(","));
        helper.getOptions(component,event);
        
    },
    handleSubmit : function(cmp, event, helper) {
        event.preventDefault();
        var fields = event.getParams('fields');
       // alert(fields);
      // fields.push("SahilHanda__Type__c");
       // fields.push("SahilHanda__Sub_Type__c");
        
        fields["SahilHanda__Type__c"] = cmp.get("v.selectedValue");
        fields["SahilHanda__Sub_Type__c"] = cmp.get("v.dependentSelectedValue");
                cmp.find('myRecordForm').submit(fields);

alert("Added") ;      
    },
    
    handleClick : function(component, event, helper) {
        console.log("In Controller : handleClick");
        helper.updateCaseStatus(component,event);
    },
    
    handleChange : function(component, event, helper){
        console.log("In Controller : handleChange");
        helper.getDependentPicklist(component, event);
    },
})