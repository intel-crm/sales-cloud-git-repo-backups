import { deleteDataset } from 'lightning/analyticsWaveApi';
import { LightningElement } from 'lwc';


/**
 * TBD header has to be sticky at certain position
 * dont care where the data comes from
 * dont have to do anything other than show an image
 * first image might be icon and everything else is svg
 * Karthik working on sticky component, can make sticky, but dont worry about scroll
 */
class IpaStoreFrontDetailHeader extends LightningElement {
  // --DRAFT FIELDS, CAN BE CHANGED BASED ON REQUIREMENT

  /**
   * Name of the icon to display
   *
   * @type {string}
   * @private
   */
  iconName;


  /**
   * Eyebrow text
   *
   * @type {string}
   * @private
   */
  eyebrow;



  /**
   * Offering headline
   *
   * @type {string}
   * @private
   */
  headLine;



  /**
   * List of badges to render
   *
   * @type {object[]}
   * @private
   */
  badges;



  /**
   * Role of the distributor
   *
   * @type {string}
   * @private
   */
  role;

  // file(){

  //   deleteDataset

  // }

}
export default IpaStoreFrontDetailHeader;