({

    setInitialValue : function(component, helper) {
      var checkboxes = component.get('v.options'),
          listOfChecked = [], complexValue = [], uniqId = 0,prereleaseArray = [];

    var delayRenderIndex = [];
    var preReleaseCount = 0;
	    
    var recurse = function(boxes, isTopLevel) {
      var anyChecked = false;
      (boxes || []).forEach(function(checkbox, idx) {
        uniqId++;
        checkbox.uniqId = component.getGlobalId() + '-performance-id-' + uniqId;
        var isChecked = checkbox.checked;
        if (checkbox.subType == 'text') {
          isChecked = (checkbox.textValue || '').length > 0;
        }
        if (checkbox.subType == 'radio') {
          isChecked = checkbox.radioOptions.find(function(opt) { return opt.isSelected; });
        }
        checkbox.checked = isChecked;
        if (isChecked) {
          anyChecked = true;
          if(checkbox.prerelease){
               prereleaseArray.push(checkbox.value); 
            }		
          listOfChecked.push(checkbox.value);
          var complexVal = Object.assign({ id: checkbox.value }, checkbox.additionalValues);
          // adds text input value
          if (checkbox.subType == 'text') complexVal.value = checkbox.textValue;
          // adds radio input value
          if (checkbox.subType == 'radio') complexVal.value = checkbox.radioOptions.find(function(opt) { return opt.isSelected; }).value;
          complexValue.push(complexVal);
        }

        var isAnyChildChecked = recurse(checkbox.children, false);
        if (component.get('v.accordionType') != 'default' && isAnyChildChecked && isTopLevel) {
          checkbox.open = true;
          checkbox.delayRender = true;
          delayRenderIndex.push(idx);
        }
      });
      return anyChecked;
    };
    recurse(checkboxes, true);

    // for performance gain... cmp uses initialCheckboxes
    // (checkboxes would be to store the data)
    // component.set('v.initialCheckboxes', checkboxes);
    console.time('PERF-FormCheckboxINITIALRenderTest-' + component.get('v.label'))
    component.set('v.checkboxes', checkboxes);
    window.setTimeout(function(){
      console.timeEnd('PERF-FormCheckboxINITIALRenderTest-' + component.get('v.label'))
    })
    
    // delay render
    var delayRenderProcess = function() {
      // check if checkbox still exists
      var idx = delayRenderIndex.shift();
      if (typeof idx != 'undefined'){
        var checkboxes = component.get('v.checkboxes');
        if (checkboxes[idx] && checkboxes[idx].delayRender) {
          helper.toggleAccordion(component, helper, idx, true);  
        }
      }
      if (delayRenderIndex.length){
        window.setTimeout(delayRenderProcess, 300);
      }
    }
    window.setTimeout(delayRenderProcess, 1500);

    // helper.renderTestPerformance(component, helper);
    helper.setInputValue(component, helper, listOfChecked, complexValue);
    if(prereleaseArray.length>0){
          component.set('v.preReleaseCount',1);
      }else{
          component.set('v.preReleaseCount',0);      
     }   
  },

    //renderTestPerformance : function(component, helper) {
    //  var checkboxes = component.get('v.checkboxes');
     // checkboxes.forEach(function(checkbox) {
      //  checkbox.getElement()
      //});
      //document.querySelector('div.checkboxAccordionSectionHeader[data-idx="'+i+'"]').classList.toggle('open');
    //},
  
    setValue : function(component, helper, value, checkboxValue) {
      var allChecked = [], complexValue = [],prereleaseArray = [],
          recursive = (component.get('v.interactionType') == 'recursive' || component.get('v.interactionType') == 'parent_recursive'),
          parent = (component.get('v.interactionType') == 'parent' || component.get('v.interactionType') == 'parent_recursive');
      var preReleaseCount = 0;
      var recurseCheckboxTree = function(boxes, recursedValue) {
          console.log("@recurseCheckboxTree",boxes);
          if(boxes)
        boxes.forEach(function(checkbox) {
            
          var newRecursedValue = undefined;
          if (checkbox.value == value) {
            // text input logic
            if (checkbox.subType == 'text') {
              checkbox.textValue = checkboxValue; // sets text value        
              checkboxValue = checkboxValue.length > 0; // "checked" if text value exists
            } else if (checkbox.subType == 'radio') {
	    	checkboxValue = checkboxValue ? true : false; // "checked" if value exists
	    }

	     // ++ performance gain
            // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
            //   helper.getElementFromUniqId(component, helper, checkbox.uniqId).checked = checkboxValue;
            // }
            checkbox.checked = checkboxValue;
            
            // recursive - set children to parents value recursively
            if (recursive) newRecursedValue = checkboxValue;
            // parent - uncheck children if parent is unchecked
            if (parent && !checkboxValue) newRecursedValue = false;
            // opens accordion
            if (component.get('v.accordionType') != 'default' && recursedValue === null) {
	      // ++ performance gain
              // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
              //   document.querySelector('div.checkboxAccordionSectionHeader[data-idx="'+'index__'+checkbox.value+'"]').classList.toggle('open', true);
              // } else {
              //   checkbox.open = true;
              // }
            }
          } else if (recursedValue != null) { // null or undefined
            checkbox.checked = recursedValue;
            // clears out text input if parent is unchecked
            if (checkbox.subType == 'text' && !recursedValue) checkbox.textValue = '';
            // clears out radio if parent is unchecked
            if (checkbox.subType == 'radio' && !recursedValue) {
              checkbox.radioOptions.forEach(function(opt) { opt.isSelected = false; });
            }
            if (recursive || parent) newRecursedValue = recursedValue;
	    // ++ performance gain
            // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
            //   helper.getElementFromUniqId(component, helper, checkbox.uniqId).checked = recursedValue;
            // }
          }

          if (checkbox.children && checkbox.children.length) {
            recurseCheckboxTree(checkbox.children, newRecursedValue);
            // recursive - after recursing tree -- uncheck parents of any unchecked
            if (recursive) {
              if (checkbox.children.find(function(c) { return !c.checked; })) {
                 checkbox.checked = false;
		
                 // ++ performance gain
                // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
                //   helper.getElementFromUniqId(component, helper, checkbox.uniqId).checked = false;
                // }
              } else {
                checkbox.checked = true;
		// ++ performance gain
                // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
                //   helper.getElementFromUniqId(component, helper, checkbox.uniqId).checked = true;
                // }
              }
            }
            // parent - after recursing tree -- check parents of any checked
            if (parent) {
              // if any children are checked, check parent
              if (checkbox.children.find(function(c) { return c.checked; }) && checkbox.label !='Select All') {
                checkbox.checked = true;
		// ++ performance gain
                // if (!checkbox.subType && component.get('v.accordionType') == 'search') {
                //   helper.getElementFromUniqId(component, helper, checkbox.uniqId).checked = true;
                // }
              }
            }
          }
            
          if (checkbox.checked) {
            if(checkbox.prerelease){
                  prereleaseArray.push(checkbox.value);
              } 		  
            allChecked.push(checkbox.value);
            var complexVal = Object.assign({ id: checkbox.value }, checkbox.additionalValues);
            // adds text input value
            if (checkbox.subType == 'text') complexVal.value = checkbox.textValue;
            // adds radio input value
            if (checkbox.subType == 'radio') complexVal.value = checkbox.radioOptions.find(function(opt) { return opt.isSelected; }).value;
            complexValue.push(complexVal);
          }
        });
        return boxes;
      };

      var updatedCheckboxes = recurseCheckboxTree(component.get('v.checkboxes'), null);
      component.set('v.checkboxes', updatedCheckboxes);
      helper.setInputValue(component, helper, allChecked, complexValue);
	    
      if(prereleaseArray.length>0){
          component.set('v.preReleaseCount',1);
      }else{
          component.set('v.preReleaseCount',0);      
      } 	    
    },

    getElementFromUniqId : function(component, helper, uniqId) {
      console.log('!!!!'. uniqId);
      return document.querySelector('div[data-uniqid="' + uniqId + '"] > lightning-input > div > span > input');
    },
    setInputValue : function(component, helper, listOfChecked, complexValue) {
      var value, oldValue = component.get('v.value');
      if (component.get('v.valueType') == 'picklist') {
        value = listOfChecked.join(';');
      } else if (component.get('v.valueType') == 'complex') {
        value = complexValue;
      } else {
        value = listOfChecked;
      }
      //Prakash 6/26 if ((oldValue && oldValue.length > 0) || value.length > 0) component.set('v.value', value);
      if (oldValue || listOfChecked.length) component.set('v.value', value);
      // console.log('here', component.get('v.apiName'), value, inputValue);
      component.set('v.valid', helper.isValid(component));
      helper.updateForm(component);
    },

    isValid : function(component) {
      if (component.get("v.required")) {
        if (!component.get("v.value") || !component.get("v.value").length) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    },

    search: function(component, helper) {
      window.setTimeout($A.getCallback(function() {
        var minimumChars = 2;
        var checkboxes = component.get('v.checkboxes');
        var q = component.get('v.searchString').toLowerCase() || false;
        // console.time('Search');
        if (q && q.length >= minimumChars) {
          q = q.replace(/[-[\]{}()*+?.,\\^$|#]/g, '\\$&');
          q = q.replace(/\s+/g,'(\\\s*?)'); // make white space variable size if it exists 
        }
      var foundFirstResult = false;
        var recurseSearchAndOpenParent = function(chckbxs) {
          var openParent = false;
          chckbxs.forEach(function(child) {
          child.firstResult = false;
            if (q && q.length >= minimumChars) {
              child.highlight = child.label.toLowerCase().match(q) ? true : false;
              if (child.subType == 'radio') {
                child.radioOptions.forEach(function(radio) {
                  radio.highlight = radio.label.toLowerCase().match(q) ? true : false;
                  if (radio.highlight) child.highlight = true;
                });
              }
            } else {
              child.highlight = false;
              if (child.subType == 'radio') {
                child.radioOptions.forEach(function(radio) {
                  radio.highlight = false;
                });
              }
            }
          if (child.highlight) {
            openParent = true;
            if (!foundFirstResult) {
              console.log(child.label);
              child.firstResult = true;
              foundFirstResult = true;
            }
          }
          if (!q && child.checked) openParent = true;
          if (child.children && child.children.length) {
            if(recurseSearchAndOpenParent(child.children)) {
              openParent = true;
            }
          }
        });
        return openParent;
      };

      checkboxes.forEach(function(checkbox) {
        checkbox.firstResult = false;
        if (q && q.length >= minimumChars) {
          checkbox.highlight = checkbox.label.toLowerCase().match(q) ? true : false;
        } else {
          checkbox.highlight = false;
        }
        if (!foundFirstResult && checkbox.highlight) {
          checkbox.firstResult = true;
          foundFirstResult = true;
        }
        checkbox.open = recurseSearchAndOpenParent(checkbox.children);
        // ++ performance gain
        // find checkbox toggle open class
      });
      // console.timeEnd('Search');
      // console.time('Setting checkboxes');
      component.set('v.checkboxes', checkboxes);
      // console.timeEnd('Setting checkboxes');
      // if (!q) helper.setInitialValue(component, helper);
      component.set('v._searching', false);
      if (component.get('v._scrollToResult')) {
        helper.scrollToFirstResult(component, helper);
      }
      component.set('v._scrollToResult', false);
    }), 50);
  },

  toggleAccordion : function(component, helper, idx, isOpen) {
      var checkboxes = component.get('v.checkboxes');
      if (checkboxes[idx]){
        var newIsOpen = !checkboxes[idx].open;
        checkboxes[idx].open = isOpen ? true : newIsOpen;
        checkboxes[idx].hasBeenRendered = true;
        checkboxes[idx].delayRender = false;
        console.time('PERF-FormCheckboxToggleAccordionRender');
        component.set('v.checkboxes', checkboxes);
        window.setTimeout(function(){
          console.timeEnd('PERF-FormCheckboxToggleAccordionRender');
        });
      }
  },

  scrollToFirstResult : function(component, helper) {
    setTimeout($A.getCallback(function() {
      var recurse = function(checkboxes, topLevel) {
        var found = false;
        for (var i = 0; i < checkboxes.length; i++) {
          var isFirstResult = false, id = checkboxes[i].getLocalId();
          if (['topLevelCheckbox', 'textInput', 'childTextInput', 'checkboxInput'].indexOf(id) > -1) {
            isFirstResult = $A.util.hasClass(checkboxes[i], 'firstResult');
            if (isFirstResult) checkboxes[i].focus();
          } else if (id == 'RadioInput' || id == 'childRadio') {
            isFirstResult = $A.util.hasClass(checkboxes[i], 'firstResult');
            if (isFirstResult) {
              // recurse radio hierarchy to find first highlighted child...
              var recurseRadio = function(option) {
                var rFound = false, children = [].concat(option.find('radioSubChild') || []);
                if (children.length) {
                  for (var j = 0; j < opts.length; j++) {
                    if (opts[j].get('v.radio.highlight')) {
                      opts[j].focus();
                      rFound = true;
                      break;
                    } else {
                      if (recurseRadio(opts[j])) { rFound = true; break; }
                    }
                  }
                }
                return rFound;
              }
              var found = false, opts = [].concat(checkboxes[i].find('radioChild') || []);
              for (var k = 0; k < opts.length; k++) {
                if (opts[k].get('v.radio.highlight')) {
                  opts[k].focus(); found = true; break;
                } else {
                  if (recurseRadio(opts[k])) { found = true; break; }
                }
              }
              if (!found) opts[0].focus();
            }
          } else if (id == 'checkbox' || topLevel) {
            var allChildren = [].concat(
              checkboxes[i].find('topLevelCheckbox') || [],
              checkboxes[i].find('checkbox') || [],
              checkboxes[i].find('checkboxInput') || [],
              checkboxes[i].find('textInput') || [],
              checkboxes[i].find('RadioInput') || [],
              checkboxes[i].find('childTextInput') || [],
              checkboxes[i].find('childRadio') || [],
              checkboxes[i].find('checkbox') || []
            );
            if (allChildren.length && recurse(allChildren)) { found = true; break; }
          }
          if (isFirstResult) {
            found = true;
            break;
          } 
        }
        return found;
      }
      recurse([component], true);
    }), 100);
  },
  showErrorMessage : function(component, helper) {
    
    	component.set('v.forceShowError', !component.get('v.valid'));   
  }

})