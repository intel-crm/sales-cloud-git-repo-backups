/** BoardingSubcomponent
 * Data used to represent a popup data
 * @typedef BoardingSubcomponent
 * @memberof ipaPartnerOnboardingService
 * @property {string} stepId the step id of the subcomponent
 * @property {string} title the title of the Boarding steps
 * @property {string} [imageUrl] the optional image url used in pre launch roles and resposibilities popup
 * @property {Content[]} content the content of the component can be text, richtext
 * @property {Content[]} [gdpr] the text of the gdpr added after the fields can be in text component can be text, richtext
 * @property {ipaPartnerOnboardingService.Field[]} [fields] the fields representing the component
 * @property {ipaPartnerOnboardingService.PartnerGroup[]} [previousGroup] the optional data used in the c-ipa-parter-group-confirmatoin
 * @property {ipaPartnerOnboardingService.PartnerGroup[]} [newGroup] the optional data used in the c-ipa-parter-group-confirmatoin
 * @property {ipaPartnerOnboardingService.DualListData} [community] the optional data used in the c-ipa-partner-communities-picklist
 * @property {string[]} [domainNames] the optional data used in the c-ipa-partner-acceptable-domains
 * @property {ipaPartnerOnboardingService.RoleTableData[]|ipaPartnerOnboardingService.ResponsibilitiesTableData[]} [tableData] the optional data used in the c-ipa-parter-role-confirmatoin
 * @property {Link} footerLinkData the optional footer link data
 * @property {Link} [closeModalAndRedrirectLinkData] the optional close and link out the page data used in onboarding last steps - used in view confirmation type, as well as the skip non submit link out
 * @property {Link} [submitFormAndRedirectLinkData] the optional submit form and link out the page data used in terms and conditions/ community picklist form submit types

 */


/** Partner Group Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef PartnerGroup
 * @memberof ipaPartnerOnboardingService
 * @property {string} title the title of the group
 * @property {ipaPartnerOnboardingService.Card[]} cards the cards belonging to the group
 */


/** Partner Group Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef Card
 * @memberof ipaPartnerOnboardingService
 * @property {string} title the title of the group
 * @property {ipaPartnerOnboardingService.Member[]} members the cards belonging to the group
 */

/** Partner Group Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef Member
 * @memberof ipaPartnerOnboardingService
 * @property {string} name the name of the member
 * @property {string} entitlement the entitlement of the member
 */

/** Role Table Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef RoleTableData
 * @memberof ipaPartnerOnboardingService
 * @property {string} icon the fa icon of the group
 * @property {string} tier the tier of the group
 * @property {string} company the company name of the group
 * @property {string} role the entitlement of the group
 */

 /** Field used in Boarding Steps
 * Data used to represent a group card in the pre boarding pages
 * @typedef Field
 * @memberof ipaPartnerOnboardingService
 * @property {string} fieldId the id of the field
 * @property {string} type the type of the field, currently we only have checkbox
 * @property {string} name the name of the field
 * @property {string} [value] the value of the of the field, currently we only have checkbox
 * @property {boolean} [checked] is the chekbox checked value
 * @property {string} type the type of the field, currently we only have checkbox
 * @property {string} label the label of the field
 * @property {boolean} required is the field a required one
 * @property {string} requiredError the error message for the field if not filled up
 */

 /** Role Table Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef ResponsibilitiesTableData
 * @memberof ipaPartnerOnboardingService
 * @property {boolean} highlight bold the row or not
 * @property {string} responsibility responsibility column
 * @property {string} employee employee column
 */


 /** Comnmunity Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef DualListData
 * @memberof ipaPartnerOnboardingService
 * @property {string} sourceLabel source label of the dual list
 * @property {string} selectedLabel selected label of the dual list
 * @property {ipaPartnerOnboardingService.Community[]} [communityOptions] the data used in the dual list
 * @property {string[]} [selectedOptions] the optional selected listdata
 * @property {string[]} [requiredOptions] the optional required Options listdata
 */


 /** Comnmunity Data
 * Data used to represent a group card in the pre boarding pages
 * @typedef Community
 * @memberof ipaPartnerOnboardingService
 * @property {string} label label of the community
 * @property {string} value unique value of the community
 */

import helpers from './helpers/index';
import ipaResource from '@salesforce/resourceUrl/IpaResources';

export const mockSubComponent = (type) => {

    let groupConfirmation = {
        stepId: helpers.id(),
        content: [
            {
              "type": "richtext",
              "body": "We're consolidating your company's previous groups. Please contact support if any changes are needed."
            }
          ],
          previousGroup: {
            "title": "Previous Groups",
            "cards": [
              {
                "title": "Amax Us Cloud Marketing - Group 1",
                "members": [
                  {
                    "name": "Alexandia Webber(You)",
                    "entitlement":"Partner Admin"
                  }
                ]
              },
              {
                "title": "Amax Us Cloud Marketing - Group 2",
                "members": [
                  {
                    "name": "Julian Lorem",
                    "entitlement":"Partner Admin"
                  }
                ]
              },
              {
                "title": "Amax Us Cloud Marketing - Group 3",
                "members": [
                  {
                    "name": "Ipsum Lorem",
                    "entitlement":"Partner Admin"
                  }
                ]
              }
            ]
          },
          newGroup: {
            "title": "New Group",
            "cards": [
              {
                "title": "Amax Us Cloud Marketing Combined",
                "members": [
                  {
                    "name": "Alexandia Webber(You)",
                    "entitlement":"Partner Admin"
                  },
                  {
                    "name": "Julian Lorem",
                    "entitlement":"Partner Admin"
                  },
                  {
                    "name": "Ipsum Lorem",
                    "entitlement":"Partner Admin"
                  }
                ]
              }
            ]
          },
          footerLinkData: {
              label: "View all tier and role definitions",
              externalUrl: "http://www.intel.com/#continue-to-itp-program",
              communityPage: "",
              objectPage: "",
              recordId: ""
          }
    }

    let tierConfirmation = {
        stepId: helpers.id(),
        content: [
          {
            type: "richtext",
            body: "Here's your current membership tier, company and role information. Please contact support if any changes are needed."
          }
        ],
        tableData:[
            {
                "icon": "fa-bookmark",
                "tier": "Titanium",
                "company" :"AMAX Engineering Corporation",
                "role": "Solution Provider"
            },
            {
                "icon": "fa-bookmark",
                "tier": "Titanium-2",
                "company" :"AMAX Engineering Corporation- 2",
                "role": "Solution Provider"
            }
        ],
        footerLinkData: {
              label: "View all tier and role definitions",
              externalUrl: "http://www.intel.com/#viewtierandroledefinitions",
              communityPage: "",
              objectPage: "",
              recordId: ""
        }
      }

    let responsibilitiesConfirmation =  {
      stepId: helpers.id(),
      title: "Verify Roles and responsibilities",
      imageUrl: ipaResource + '/images/intel-logo.png',
      content: [
        {
          type: "richtext",
          body: "The roles and responsibilities of your team members are listed below. Click on the Manage Personnel link to make changes."
        }
      ],
      tableData: [
        {
          highlight: true,
          responsibility: "Partner Admin",
          employee: "Julia Go(You)"
        },
        {
          highlight: false,
          responsibility: "Warranty Requestor",
          employee: "open"
        },
        {
          highlight: false,
          responsibility: "Primary Lead Designated Rep",
          employee: "open"
        },
        //IPA2.0:US-4497-1631_OfferingEOL
        // {
        //   highlight: false,
        //   responsibility: "Offering Editor",
        //   employee: "open"
        // },
        {
          highlight: false,
          responsibility: "Marketing Specialist",
          employee: "open"
        },
        {
          highlight: false,
          responsibility: "Points Manager",
          employee: "open"
        },
        {
          highlight: false,
          responsibility: "Activity Logger",
          employee: "open"
        },
        {
          highlight: false,
          responsibility: "Claims Analyst",
          employee: "open"
        }
      ],
      closeModalAndRedrirectLinkData: {
        label: "Close",
        externalUrl: "https://iqa2cqcontent.cps.intel.com/content/www/us/en/ipa-homepage-loggedIn.html"
      },
      footerLinkData: {
        label: "Manage Personnel",
        externalUrl: "http://www.intel.com/#manageresponsibilities",
        communityPage: "",
        objectPage: "",
        recordId: ""
      }
    }


    let termsAndConditions =  {
        stepId: helpers.id(),
        title: "Accept Terms and conditions",
        content: [
          {
            type: "richtext",
            body: "<p>Please read and accept the following terms and conditions of the new Intel partner alliance" +
            "<ol> " +
            "<li>Lorem ipsum dolor sit amet, id est purto dolorum platonem, solum justo lorem ei pro. Te sea congue nostrud, an quem virtute concludaturque eum. Inani luptatum id cum, ubique tibique cu est. Ad has dolor consectetuer, sapientem aliquando ad pro. Malis falli zril cu eam.</li>" +
            "<li>Est simul albucius ea, an solum abhorreant accommodare eum, te duis definitiones vim. Probo adipisci in eam. Per ad quot cetero. Mei docendi lobortis tincidunt et. Eius suscipit in mea, usu ea admodum iracundia. An elitr nonumes instructior eos, te natum dolorum mei, ad nec debet adipisci democritum.</li>" +
            "<li>Falli periculis ea sed, te vis veniam accusam reprimique. Congue honestatis scripserit vis ei, et oportere interpretaris sea. Mel regione luptatum cu. Vix cu iriure patrioque voluptaria, ut dolorem mentitum expetenda pro.</li>" +
            "<li>Vel et illud recteque, errem everti theophrastus his ad. Et nam liber tritani assueverit. Ea sea novum commodo, eu sea malis minim. Ei nam idque dicant. Iusto adipiscing vel ad, in sanctus scripserit vel. Sea alii inani in. Partem viderer eam an.</li>" +
            "<li>Natum mnesarchum ad mel, solet repudiare eu duo, ei mea natum falli dicunt. Erat molestiae expetendis nec ea, an wisi dolorum sit. At scaevola sensibus eam. Eos quot accumsan elaboraret et, sit ut dicam conceptam, prompta accumsan omnesque cu vim. Pro adhuc semper regione et.</li>" +
            "<li>Sea ex alii dolor causae. Eu tale habemus officiis sed, sea te ridens nostro molestiae. Sit possim verear inciderint eu, usu unum possit eu. Eos et iusto volutpat. Ei accusamus assentior vix, facer vocibus deleniti sit ut. His id liberavisse contentiones, cum dictas everti noluisse eu.</li>" +
            "<li>Vix ornatus suscipit scripserit ea, cibo vivendo periculis at vis, ut his oportere assueverit. Et illum mazim expetendis has, est maluisset euripidis no. Ex his tale viris, usu invidunt disputationi ei. Est eleifend scripserit an, duo dolor tamquam patrioque no. Erant homero interesset ad mel, an melius aliquip aperiam qui.</li>" +
            "<li>Mel et regione contentiones, no nihil ornatus ocurreret sea, te augue summo nec. Cum simul accusamus evertitur et, sed te commune qualisque concludaturque. Nam error dolorem deterruisset ut, eu bonorum intellegebat sea. Has in utamur similique, nec fugit zril oportere ad. Te usu quem recusabo.</li>" +
            "<li>Everti luptatum eum ad. Euismod delicata usu eu. No mei dicunt erroribus tincidunt, ius laudem veritus molestie eu. Qui discere aliquam adolescens ei, novum solet perfecto eos eu. Nec in illum malis assueverit, an dicat laudem qui.</li>" +
            "<li>Cum ea nibh nullam, ad populo ocurreret mel. Eu nisl melius constituto qui, pri at nostrum salutatus, choro quaerendum in sea. In mea debitis adipisci cotidieque, mei at diceret consequat. Qui nullam inciderint cotidieque an, omittam liberavisse ut has. Sed timeam necessitatibus eu, ne pri timeam explicari tincidunt. Ius odio putent fabellas eu. Eos at dico clita deleniti, quodsi omittantur dissentiunt ex ius.</li>" +
            "<li>Mea cu tempor nostrum, omnesque suscipiantur at pri. Qui ne quem unum harum, omnis mazim qui ne, veri periculis sit in. Alii inciderint nam id, option legimus efficiendi ut nec, quo officiis invidunt ut. Salutandi vulputate sea et, mel no accumsan legendos consulatu.</li>" +
            "<li>Te pro altera utroque, ex pri veri reque abhorreant. Te scripta offendit qualisque vel. Sed quando appetere deseruisse ei, ei est eros mediocritatem. Te nec esse deseruisse dissentiunt, no mei aeque latine persecuti. Affert lucilius vix id.</li>" +
            "<li>Qui at euripidis honestatis, id quo duis alienum copiosae, vix inani mundi epicuri ut. Soluta graeci argumentum has no. Unum cetero scripta vis cu. Eam cu legere viderer noluisse, ut legere latine suavitate ius. Ex mel harum cetero, eum accusam laboramus te. Unum indoctum id pri, stet singulis quo te.</li>" +
            "<li>In qui purto idque munere, ea definiebas conclusionemque vis. An sea dolorem suavitate. Laudem accusamus suscipiantur cu sea, ne latine suscipit vix, choro alienum referrentur id sit. Soleat feugait et mea, ei fuisset laboramus eos. Ea quod omnes aeterno usu.</li>" +
            "<li>Cum ne placerat urbanitas reprimique. Sed id nulla alienum explicari, brute graeco ornatus eu est. Ad bonorum vivendo pri, pro vero omnesque eu. Eos postea incorrupte ad.</li>" +
            "</ol>"
          }
        ],
        fields: [
          {
            fieldId: "XX-1",
            type: "Checkbox",
            name: "terms-and-conditions",
            value: "checkbox-terms-conditions",
            checked: false,
            label: "<b>If you agree to the Intel® Partner Alliance Terms and Conditions and the Intel® Partner Alliance Trademark License, click ”SUBMIT”. If you do not agree, click “CANCEL”.</b> If you click Submit, and if you are agreeing on behalf of a company or other legal entity, you represent and warrant to Intel that you have the legal authority to bind that legal entity to the Intel® Partner Alliance Terms and Conditions and the Intel® Partner Alliance Trademark License. Further, you acknowledge and agree that the Company is entering into a contractual obligation and is contractually bound by such terms and conditions, upon confirmation of acceptance by Intel.  If you Cancel, you understand that you are not participating in the program and you are not licensed to use the Intel logos and badges.",
            required: true,
            requireError: "This field is required",
          }
        ],
        gdpr: [
          {
            type: "richtext",
            body: "<hr><p>Intel will use your personal information collected at registration and in connection with the program for the following purposes: to deliver member benefits such as financial incentives or customer support programs; to deliver member services such as newsletters, events or training activities and other content relevant to members; to ensure our program websites are relevant to the needs of our members; and to inform members of new product offerings, product discontinuances, special offers, updated information and other benefits or services available to members.  For more information on Intel’s privacy practices please visit the <a href=\"https://www.intel.com/content/www/us/en/privacy/intel-privacy-notice.html\" target=\"_blank\">Intel Privacy Notice.</a></p>" +
            "<p>You may update your settings and communication preferences on the program website at any time by clicking the ‘My Intel’ link. Note, however, communications concerning your account status, such as membership renewal reminders, program changes, and training assignment are not subject to opt-out.</p>"
          }
        ]
    }

    let termsAndConditionsNonPrimary =  {
      stepId: helpers.id(),
      title: "View Terms and conditions",
      content: [
        {
          type: "richtext",
          body: "<p>Please read and accept the following terms and conditions of the new Intel partner alliance</p>" +
          "<ol> " +
          "<li>Lorem ipsum dolor sit amet, id est purto dolorum platonem, solum justo lorem ei pro. Te sea congue nostrud, an quem virtute concludaturque eum. Inani luptatum id cum, ubique tibique cu est. Ad has dolor consectetuer, sapientem aliquando ad pro. Malis falli zril cu eam.</li>" +
          "<li>Est simul albucius ea, an solum abhorreant accommodare eum, te duis definitiones vim. Probo adipisci in eam. Per ad quot cetero. Mei docendi lobortis tincidunt et. Eius suscipit in mea, usu ea admodum iracundia. An elitr nonumes instructior eos, te natum dolorum mei, ad nec debet adipisci democritum.</li>" +
          "<li>Falli periculis ea sed, te vis veniam accusam reprimique. Congue honestatis scripserit vis ei, et oportere interpretaris sea. Mel regione luptatum cu. Vix cu iriure patrioque voluptaria, ut dolorem mentitum expetenda pro.</li>" +
          "<li>Vel et illud recteque, errem everti theophrastus his ad. Et nam liber tritani assueverit. Ea sea novum commodo, eu sea malis minim. Ei nam idque dicant. Iusto adipiscing vel ad, in sanctus scripserit vel. Sea alii inani in. Partem viderer eam an.</li>" +
          "<li>Natum mnesarchum ad mel, solet repudiare eu duo, ei mea natum falli dicunt. Erat molestiae expetendis nec ea, an wisi dolorum sit. At scaevola sensibus eam. Eos quot accumsan elaboraret et, sit ut dicam conceptam, prompta accumsan omnesque cu vim. Pro adhuc semper regione et.</li>" +
          "<li>Sea ex alii dolor causae. Eu tale habemus officiis sed, sea te ridens nostro molestiae. Sit possim verear inciderint eu, usu unum possit eu. Eos et iusto volutpat. Ei accusamus assentior vix, facer vocibus deleniti sit ut. His id liberavisse contentiones, cum dictas everti noluisse eu.</li>" +
          "<li>Vix ornatus suscipit scripserit ea, cibo vivendo periculis at vis, ut his oportere assueverit. Et illum mazim expetendis has, est maluisset euripidis no. Ex his tale viris, usu invidunt disputationi ei. Est eleifend scripserit an, duo dolor tamquam patrioque no. Erant homero interesset ad mel, an melius aliquip aperiam qui.</li>" +
          "<li>Mel et regione contentiones, no nihil ornatus ocurreret sea, te augue summo nec. Cum simul accusamus evertitur et, sed te commune qualisque concludaturque. Nam error dolorem deterruisset ut, eu bonorum intellegebat sea. Has in utamur similique, nec fugit zril oportere ad. Te usu quem recusabo.</li>" +
          "<li>Everti luptatum eum ad. Euismod delicata usu eu. No mei dicunt erroribus tincidunt, ius laudem veritus molestie eu. Qui discere aliquam adolescens ei, novum solet perfecto eos eu. Nec in illum malis assueverit, an dicat laudem qui.</li>" +
          "<li>Cum ea nibh nullam, ad populo ocurreret mel. Eu nisl melius constituto qui, pri at nostrum salutatus, choro quaerendum in sea. In mea debitis adipisci cotidieque, mei at diceret consequat. Qui nullam inciderint cotidieque an, omittam liberavisse ut has. Sed timeam necessitatibus eu, ne pri timeam explicari tincidunt. Ius odio putent fabellas eu. Eos at dico clita deleniti, quodsi omittantur dissentiunt ex ius.</li>" +
          "<li>Mea cu tempor nostrum, omnesque suscipiantur at pri. Qui ne quem unum harum, omnis mazim qui ne, veri periculis sit in. Alii inciderint nam id, option legimus efficiendi ut nec, quo officiis invidunt ut. Salutandi vulputate sea et, mel no accumsan legendos consulatu.</li>" +
          "<li>Te pro altera utroque, ex pri veri reque abhorreant. Te scripta offendit qualisque vel. Sed quando appetere deseruisse ei, ei est eros mediocritatem. Te nec esse deseruisse dissentiunt, no mei aeque latine persecuti. Affert lucilius vix id.</li>" +
          "<li>Qui at euripidis honestatis, id quo duis alienum copiosae, vix inani mundi epicuri ut. Soluta graeci argumentum has no. Unum cetero scripta vis cu. Eam cu legere viderer noluisse, ut legere latine suavitate ius. Ex mel harum cetero, eum accusam laboramus te. Unum indoctum id pri, stet singulis quo te.</li>" +
          "<li>In qui purto idque munere, ea definiebas conclusionemque vis. An sea dolorem suavitate. Laudem accusamus suscipiantur cu sea, ne latine suscipit vix, choro alienum referrentur id sit. Soleat feugait et mea, ei fuisset laboramus eos. Ea quod omnes aeterno usu.</li>" +
          "<li>Cum ne placerat urbanitas reprimique. Sed id nulla alienum explicari, brute graeco ornatus eu est. Ad bonorum vivendo pri, pro vero omnesque eu. Eos postea incorrupte ad.</li>" +
          "</ol>"
        }
      ],
      fields: [
        {
          fieldId: "XX-1",
          type: "Checkbox",
          name: "terms-and-conditions",
          value: "checkbox-terms-conditions",
          checked: false,
          label: "<b>If you agree to the Intel® Partner Alliance Terms and Conditions and the Intel® Partner Alliance Trademark License, click ”SUBMIT”. If you do not agree, click “CANCEL”.</b> If you click Submit, and if you are agreeing on behalf of a company or other legal entity, you represent and warrant to Intel that you have the legal authority to bind that legal entity to the Intel® Partner Alliance Terms and Conditions and the Intel® Partner Alliance Trademark License. Further, you acknowledge and agree that the Company is entering into a contractual obligation and is contractually bound by such terms and conditions, upon confirmation of acceptance by Intel.  If you Cancel, you understand that you are not participating in the program and you are not licensed to use the Intel logos and badges.",
          required: true,
          requireError: "This field is required",
        }
      ],
      gdpr: [
        {
          type: "richtext",
          body: "<hr><p>Intel will use your personal information collected at registration and in connection with the program for the following purposes: to deliver member benefits such as financial incentives or customer support programs; to deliver member services such as newsletters, events or training activities and other content relevant to members; to ensure our program websites are relevant to the needs of our members; and to inform members of new product offerings, product discontinuances, special offers, updated information and other benefits or services available to members.  For more information on Intel’s privacy practices please visit the <a href=\"https://www.intel.com/content/www/us/en/privacy/intel-privacy-notice.html\" target=\"_blank\">Intel Privacy Notice.</a></p>" +
          "<p>You may update your settings and communication preferences on the program website at any time by clicking the ‘My Intel’ link. Note, however, communications concerning your account status, such as membership renewal reminders, program changes, and training assignment are not subject to opt-out.</p>"
        }
      ]
  }

     let communitySelection =  {
        stepId: helpers.id(),
        title: "Communities(Optional)",
        content: [
          {
            type: "richtext",
            body: "Add any additional communities of interest to you from the list of those available provided below. Selected communities with a lock icon cannot be deselected."
          }
        ],
        community: {
          sourceLabel: 'Available Communities',
          selectedLabel: 'Selected Communities',
          communityOptions: [
            { value: 'fpga', label: 'FPGA' },
            { value: 'cloud-service-providers', label: 'Cloud Service Providers' },
            { value: 'iot solutions', label: 'IOT Solutions' },
            { value: 'lorem ipsum', label: 'Lorem Ipsum' },
            { value: 'community-req', label: 'Community Lorem -req' },
          ],
          selectedOptions: ['fpga'],
          requiredOptions: ['community-req']
        },
        footerLinkData: {
          label: "Manage Responsibilities",
          externalUrl: "http://www.intel.com/#manageresponsibilities",
          communityPage: "",
          objectPage: "",
          recordId: ""
        }
      }


     let communitySelectionNonPrimary =  {
      stepId: helpers.id(),
      title: "Communities(Optional)",
      content: [
        {
          type: "richtext",
          body: "Add any additional communities of interest to you from the list of those available provided below. Selected communities with a lock icon cannot be deselected."
        }
      ],
      community: {
        sourceLabel: 'Available Communities',
        selectedLabel: 'Selected Communities',
        communityOptions: [
          { value: 'fpga', label: 'FPGA' },
          { value: 'cloud-service-providers', label: 'Cloud Service Providers' },
          { value: 'iot solutions', label: 'IOT Solutions' },
          { value: 'lorem ipsum', label: 'Lorem Ipsum' },
        ],
        selectedOptions: ['fpga']
      },
      submitFormAndRedirectLinkData: {
        label: "Submit",
        externalUrl: "http://www.intel.com/#submitFormAndRedirectLinkData"
      },
      closeModalAndRedrirectLinkData: {
        label: "Close",
        externalUrl: "http://www.intel.com/#closeFormAndRedirectLinkData"
      },
      footerLinkData: {
        label: "Manage Responsibilities",
        externalUrl: "http://www.intel.com/#manageresponsibilities",
        communityPage: "",
        objectPage: "",
        recordId: ""
      }
    }

      let domainSelection =  {
        stepId: helpers.id(),
        title: "Acceptable Domains(Optional)",
        content: [
          {
            type: "richtext",
            body: "<p>Click on the link below to manage your acceptable domains. Defining acceptable domains allows your team members to join seamlessly.</p>"
          }
        ],
        footerLinkData: {
          label: "Manage Acceptable Domains",
          externalUrl: "http://www.intel.com/#manageresponsibilities",
          communityPage: "",
          objectPage: "",
          recordId: ""
        }
      }


    switch (type) {
        case 'grouping-confirmation':
            return groupConfirmation;

        case 'tier-confirmation':
            return tierConfirmation;

        case 'terms-and-conditions':
            return termsAndConditions;

        case 'terms-and-conditions-non-primary':
            return termsAndConditionsNonPrimary;

        case 'responsibilities-confirmation':
            return responsibilitiesConfirmation;

        case 'community-picklist':
            return communitySelection;

        case 'community-picklist-non-primary':
            return communitySelectionNonPrimary;

        case 'acceptable-domains':
            return domainSelection;

        default:
            return groupConfirmation;
    }
}