import { LightningElement, api } from 'lwc';
import { ipaMarqueeMarketplaceData } from 'c/ipaMarqueeMarketplace';
import IpaCampaignService from 'c/ipaCampaignService';
import learnMore from '@salesforce/label/c.PMP_Learn_More';

/**
 * This component gets marquee data for the Campaign/Event pages
 *
 * @augments LightningElement
 * @property {object} campaign campaign data
 */
class IpaCampaignMarqueeData extends LightningElement {
    @api campaign;

    /**
     * connected callback
     * - gets campaign data from IpaCampaignService
     * - publishes marquee data for dynamic marquee
     */
    connectedCallback() {
      IpaCampaignService.getCampaignDetails().then((campaign = {}) => {
        const payload = {
          title: campaign.name || '[missing campaign Name]',
          subtitle: campaign.description || '[missing campaign description',
          showCaret: true,
          linkData: {
            label: learnMore, //  custom label
            externalUrl: campaign.externalUrl || 'https://www.intel.com', //  made dynamic

          },
        };
        ipaMarqueeMarketplaceData.setData(payload);
      });
    }
}
export default IpaCampaignMarqueeData;