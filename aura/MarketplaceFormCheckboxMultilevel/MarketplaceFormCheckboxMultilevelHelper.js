({

  setInitialValue : function(component, helper) {
    var checkboxes = component.get('v.options'),
        listOfChecked = [], complexValue = [], uniqId = 0;
    var listOfExpandedParent = [];

    var delayRenderIndex = [];

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
        
        // Addon to expand parents that are selected
        if (isAnyChildChecked) {
          listOfExpandedParent.push(checkbox.value);
        }

      });
      return anyChecked;
    };
    recurse(checkboxes, true);

    // for performance gain... cmp uses initialCheckboxes
    // (checkboxes would be to store the data)
    // component.set('v.initialCheckboxes', checkboxes);
    component.set('v.expandedSections', listOfExpandedParent);

    console.time('PERF-FormCheckboxINITIALRenderTest-' + component.get('v.label'))
    checkboxes = helper.updateTotalValues(checkboxes);
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
    
  },

  // renderTestPerformance : function(component, helper) {
  //   var checkboxes = component.get('v.checkboxes');
  //   checkboxes.forEach(function(checkbox) {
  //     checkbox.getElement()
  //   });
  //   document.querySelector('div.checkboxAccordionSectionHeader[data-idx="'+i+'"]').classList.toggle('open');
  // },

  setValue : function(component, helper, value, checkboxValue) {
    var allChecked = [], complexValue = [],
        recursive = component.get('v.interactionType') == 'recursive',
        parent = component.get('v.interactionType') == 'parent',
        recursiveSelect = component.get('v.interactionType') == 'recursiveselect',
        collapsed = component.get('v.collapsible');
    
    var listOfExpandedParent = [];

    var recurseCheckboxTree = function(boxes, recursedValue) {
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

          checkbox.checked = checkboxValue;

          // recursive - set children to parents value recursively
          if (recursive) newRecursedValue = checkboxValue;
          // parent - uncheck children if parent is unchecked
          if (parent && !checkboxValue) newRecursedValue = false;
          // recursiveselect - set children if selected
          if (recursiveSelect && checkboxValue) newRecursedValue = true;
          
        } else if (recursedValue != null) { // null or undefined
          checkbox.checked = recursedValue;
          // clears out text input if parent is unchecked
          if (checkbox.subType == 'text' && !recursedValue) checkbox.textValue = '';
          // clears out radio if parent is unchecked
          if (checkbox.subType == 'radio' && !recursedValue) {
            checkbox.radioOptions.forEach(function(opt) { opt.isSelected = false; });
          }
          if (recursive || parent || recursiveSelect) newRecursedValue = recursedValue;
        }

        if (checkbox.children && checkbox.children.length) {
          recurseCheckboxTree(checkbox.children, newRecursedValue);
          // recursive - after recursing tree -- uncheck parents of any unchecked
          if (recursive) {
            if (checkbox.children.find(function(c) { return !c.checked; })) {
               checkbox.checked = false;
            } else {
              checkbox.checked = true;
            }
          }
          // parent - after recursing tree -- check parents of any checked
          if (parent) {
            // if any children are checked, check parent
            if (checkbox.children.find(function(c) { return c.checked; })) {
              checkbox.checked = true;
            }
          }
          // collapsed type
          if (collapsed) {
            if (newRecursedValue) {
              listOfExpandedParent.push(checkbox.value);
            }
          }

        }

        if (checkbox.checked) {
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
    updatedCheckboxes = helper.updateTotalValues(updatedCheckboxes);
    component.set('v.checkboxes', updatedCheckboxes);
    // update expandeds sections
    component.set('v.expandedSections', helper.uniqueArray(listOfExpandedParent, component.get('v.expandedSections')));
    helper.setInputValue(component, helper, allChecked, complexValue);
  },

  getElementFromUniqId : function(component, helper, uniqId) {
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
    if (oldValue || listOfChecked.length) component.set('v.value', value);
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

      var collapsed = component.get('v.collapsible');
      var listOfExpandedParent = [];

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
              if (collapsed) {
                listOfExpandedParent.push(child.value);
              }
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
      // update expanded sections
      component.set('v.expandedSections', helper.uniqueArray(listOfExpandedParent, component.get('v.expandedSections')));
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
    // TODO
  },

  toggleSection: function(component, helper, checkboxValue){
    var expandedSections = component.get('v.expandedSections') || [];
    var index = expandedSections.indexOf(checkboxValue);
    if (index > -1) {
      console.log('subract from section',expandedSections);
      console.log(expandedSections.length);
      expandedSections.splice(index, 1);
      console.log(expandedSections.length);
    } else if (index == -1) {
      console.log('Add to section');

      expandedSections.push(checkboxValue);
    }
    console.log('ExpandedSections', index, JSON.parse(JSON.stringify(expandedSections)), JSON.parse(JSON.stringify(component.get('v.expandedSections'))), checkboxValue);
    component.set('v.expandedSections', expandedSections);
  },

  toggleChildren : function(component, helper, value, checkboxValue) {
    var allChecked = [], complexValue = [],
        collapsed = component.get('v.collapsible');
    
    var listOfExpandedParent = [];

    var recurseCheckboxTree = function(boxes, recursedValue) { 
      boxes.forEach(function(checkbox) {
        var newRecursedValue = undefined;

        if (checkbox.value == value) {
          // text input logic
          newRecursedValue = checkboxValue;
          // Toggles parent 
          // checkbox.checked = checkboxValue;
          if (checkboxValue)
            checkbox.open =  true;
        } else if (recursedValue != null) { // null or undefined
          checkbox.checked = recursedValue;
          // clears out text input if parent is unchecked
          if (checkbox.subType == 'text' && !recursedValue) checkbox.textValue = '';
          // clears out radio if parent is unchecked
          if (checkbox.subType == 'radio' && !recursedValue) {
            checkbox.radioOptions.forEach(function(opt) { opt.isSelected = false; });
          }
          newRecursedValue = recursedValue;
        }

        if (checkbox.children && checkbox.children.length) {
          recurseCheckboxTree(checkbox.children, newRecursedValue);
          
          if (collapsed) {
            if (newRecursedValue) {
              listOfExpandedParent.push(checkbox.value);
            }
          }

        }

        if (checkbox.checked) {
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
    updatedCheckboxes = helper.updateTotalValues(updatedCheckboxes);
    component.set('v.checkboxes', updatedCheckboxes);
    
    component.set('v.expandedSections', helper.uniqueArray(listOfExpandedParent, component.get('v.expandedSections')));
    console.log(component.get('v.expandedSections'));
    helper.setInputValue(component, helper, allChecked, complexValue);
  },

  uniqueArray: function(array1, array2) {
    var mergedArray = array1.concat(array2);
    return mergedArray.filter(function(elem, index){ return mergedArray.indexOf(elem) === index}); ;
  },

  updateTotalValues: function(array) {

    var recurseDescendantCheckedCount = function(boxes, top) {
      var totalDescendantCount = 0;

      boxes.forEach(function(checkbox) {
        var _currentDescendant = 0;

        if (checkbox.children && checkbox.children.length) {
          _currentDescendant = recurseDescendantCheckedCount(checkbox.children);
        }
        if (checkbox.checked) {
          _currentDescendant++;
        }
        checkbox.totalSelected = _currentDescendant;
        totalDescendantCount += _currentDescendant;

      });
      return totalDescendantCount;
    };

    recurseDescendantCheckedCount(array);

    return array;
  }

})