import { LightningElement, api } from 'lwc';
import { ipaMarqueeMarketplaceData } from 'c/ipaMarqueeMarketplace';
import IpaTopicService from 'c/ipaTopicService';

/**
 * This component gets marquee data for the Topic/Event pages
 *
 * @augments LightningElement
 * @property {object} topic topic data
 */
class IpaTopicMarqueeData extends LightningElement {
  @api topic;

  /**
   * connected callback
   * - gets topic data from IpaTopicService
   * - publishes marquee data for dynamic marquee
   */
//IPA2.0:TWC729-8114 Topics Removal/Event Removal
//  connectedCallback() {
//    IpaTopicService.getTopicDetails().then((topic = {}) => {
//      const payload = {
//        title: topic.name,
//        subtitle: topic.description,
//        showCaret: true,
//      };
//      if (topic !== undefined) {
//        ipaMarqueeMarketplaceData.setData(payload);
//      }
//    });
//  }
}
export default IpaTopicMarqueeData;