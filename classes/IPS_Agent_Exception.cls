public class IPS_Agent_Exception extends Exception {

    public static final String CASE_NOT_FOUND =
        'Case not found';

    public static final String CASE_NUMBER_REQUIRED =
        'Case Number is required';

    public static final String COMMENT_REQUIRED =
        'Comment is required';

    public static final String INVALID_STATUS =
        'Invalid status supplied';
}

//throw new IPS_Agent_Exception(
//    IPS_Agent_Exception.CASE_NOT_FOUND
//);