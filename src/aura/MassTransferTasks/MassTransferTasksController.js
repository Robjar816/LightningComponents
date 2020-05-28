({
    init : function(component, event, helper) {
        helper.getColumnAndAction(component, event);
        helper.getActions(component, event);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Mass Transfer Tasks" //set label you want to set
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:add_contact", //set icon you want to set
                iconAlt: "Mass Transfer Tasks" //set label tooltip you want to set
            });
        })
        
    },
    
    handleMassTransfer : function(component, event, helper) {
        var rows = component.find('customSettingTable').getSelectedRows();
        console.log(JSON.stringify(rows));
        
        component.set("v.assignOwner", true);

    },
    
    //To close the quick action popup
    handleClose : function(component, event, helper) {
        component.set("v.assignOwner", false);
        $A.get("e.force:closeQuickAction").fire();
    },
})