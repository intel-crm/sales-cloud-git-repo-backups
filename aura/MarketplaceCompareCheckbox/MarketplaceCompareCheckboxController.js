({
    
    doInit : function(component, event, helper) {
        var index=0;
        component.set('v.mapStateToAttributes', function(state) {
            
            return {
                
                checked: state.items.find(function(i) {
                    return i.id == component.get('v.item.id');
                    
                })
            };
        });
    },
    
    //Check Add to Compare button -Gireesh :US519754
    handleItemChange: function(component, event, helper) {
        console.log('items.state',component.get('v.state'));
        if(component.get('v.state')!=null && component.get('v.item')!=null){
            var items=component.get('v.state').items;
            var item=component.get('v.item');
            console.log('items',items);
            console.log('item',item);
            var checked=false;
            if(item!=null && item!=undefined && items!=null && items!=undefined){
                for(var idx=0; idx<items.length;idx++){
                    if(items[idx].id==item.id){
                        checked=true;
                        break;
                    }    
                }
            }
            component.set("v.checked",checked);
        }
        
    },
    handleCheckCompare: function(component, event, helper) {
        
        var trayItems = component.get('v.state').items;
        if (event.currentTarget.checked &&
            trayItems.length >0 && trayItems.length < 4) {
            // checks to see if the category matches other items in the compare tray
            var currentTray = component.get('v.state').items;
            console.log("currentTray",currentTray);
            var currentCategories = currentTray.reduce(function(categories, item) {
                var cat = item.attributes.find(function(a) { return a.name == $A.get("$Label.c.PMP_Search_Categories_Filter"); });
                if (cat && cat.types) {
                    cat.types.forEach(function(c) {
                        if (!categories.find(function(t) { return t.id == c.id; })) {
                            categories.push(c);
                        }
                    });
                }
                
                return categories;
            }, []);
            //
            var category = component.get('v.item').attributes.find(function(a) {
                return a.name == $A.get("$Label.c.PMP_Search_Categories_Filter");
            });
            
            //added by raj to modify compare logic,getting second Tier category from product available in compare tray 
            if(currentCategories){
                var currentCat=currentCategories.find(function(x){return x.secondTierCat==true;});
            }
            
            //getting second Tier category from product which is to be added in the compare tray
            if(category){
                for(var type of category.types){
                    if(type.secondTierCat==true){
                        var cat=type;
                    }
                }
            }
            
            var matchesCategory=false;
            //checking if the second tier matches 
            if(!(cat==null ||currentCat==null)){
                if(cat.id==currentCat.id){
                    matchesCategory=true;}
                else{
                    matchesCategory=false;}
            }
            else{
                matchesCategory=false;}
            /*if (category.types) {
        category.types.forEach(function(c) {
          var match = currentCategories.find(function(c2) { return c2.id == c.id });
          if (!match) matchesCategory = false;
        });
      }*/
        if (!matchesCategory) {
            helper.dispatch(component, 'showCompareTrayNotification', {
                msg: $A.get("$Label.c.PMP_CategoryNotMatched")
            });
            event.currentTarget.checked = false;
            return;
        }
    } else if (event.currentTarget.checked && trayItems.length > 3) {
        helper.dispatch(component, 'showCompareTrayNotification', {
            msg: $A.get("$Label.c.PMP_CompareTray_Full_Warning")
        });
        event.currentTarget.checked = false;
        return;
    }
     
     helper.dispatch(component, 'toggleCompareTrayItem', { item: component.get('v.item') });
 },
    
    
})