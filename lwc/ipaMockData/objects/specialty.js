/** Partner Specialty
 * @typedef Specialty
 * @property {string} title title (ie. "Enthusiast PC Specialist")
 * @property {string} [iconImgUrl] image src for an image to be used as an icon
 * @property {string} [icon] icon name for custom font icon use (ie. 'fa-cancel')
 * @property {string} [sfIcon] [Salesforce]{@link https://lightningdesignsystem.com/icons/#utility} Salesforce icon name
 */

export const mockSpecialties = () => [
    { title: 'Industrial Solutions Builder Specialist', iconImgUrl: 'https://marketplace.intel.com/servlet/servlet.ImageServer?id=0153b000004Pg4n&oid=00Do0000000aRcf&lastMod=1570256505000' },
    { title: 'Retail Visual Solutions Specialist', sfIcon: 'utility:preview' },
    { title: 'Video Specialist', sfIcon: 'utility:video' },
    { title: 'High Performance Computing Specialist', icon: 'fa-server' },
    { title: 'Enthusiast PC Specialist', sfIcon: 'utility:puzzle' },
    { title: 'Cloud Data Center Specialist', icon: 'fa-cloud' },
    { title: 'Artificial Intelligence Specialist', icon: 'fa-beaker' }
]