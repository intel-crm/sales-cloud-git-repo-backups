/*********************************************************************************************************************************************************************************
 * Class Name      : Core_MDF_OutcomeDiffReportWrapper
 * Author          : Indu
 * Created Date    : Jul 3, 2026
 * Last Modified By: Indu
 * Last Modified On: Jul 3, 2026
 * Description     : This wrapper class is used to hold Outcome Based Activity difference report data.
 *                   It stores Super Activity details, Sub Activity details, account/funding split details,
 *                   compared field information, expected value, and actual value for each mismatch row.
 *
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jul 3, 2026  │   Indu       │   Initial version
 *********************************************************************************************************************************************************************************/

public class Core_MDF_OutcomeDiffReportWrapper {

    public String differenceType;

    public Id superActivityId;
    public String superActivityNumber;
    public String superActivityTitle;

    public Id accountId;
    public String accountName;

    public Id subActivityId;
    public String subActivityNumber;
    public String subActivityTitle;

    public Id fundingSplitRecordId;
    public Decimal fundingSplitPercent;
    public Decimal fundingSplitAmount;

    public String fieldApiName;
    public String fieldLabel;
    public String expectedValue;
    public String actualValue;

    public Datetime superActivityCreatedDate;
    public Id superActivityCreatedById;
}