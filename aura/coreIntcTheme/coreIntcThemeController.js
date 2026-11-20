({
  /**
  * Creates a dynamic ltng:require component in order to load
  * additional CSS files that are specified by the additionalCss design attribute.
  *
  * @param {Object} component  The Lightning web component.
  * @param {Object} event  The aura event thrown on init.
  * @param {Object} helper  The helper component.
  */
  doInit: function(component, event, helper) {
    const additionalCss = component.get('v.additionalCss');
    // Check if any CSS files were specified
    if (additionalCss) {
      try {
        const cssConfig = JSON.parse(additionalCss);
        const resources = Object.keys(cssConfig);
        const filePaths = [];
        let files = [];
        let resourcePath;

        // Loop through each static resource specified
        resources.forEach((resource) => {
          // Get the path to that static resource
          resourcePath = $A.get(`$Resource.${resource}`);

          // Add each file specified for that static resource
          files = cssConfig[resource];
          files.forEach((file) => {
            filePaths.push(`${resourcePath}/${file}`);
          });
        });

        // Dynamically create a require component. Doing this since
        // couldn't determine a way to use variables in a static require.
        $A.createComponent('ltng:require', {
          styles: filePaths,
        }, function(dynamicComponent) {
            component.set('v.renderDynamicRequire', true);
            component.set('v.dynamicRequire', [dynamicComponent]);
        });
      } catch (ex) {
        console.error('Error in coreIntcThemeController additionalCss ', ex);
      }
    }
  },
});