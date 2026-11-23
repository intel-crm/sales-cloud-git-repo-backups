public class TestApp {
    private static boolean isflag=false;
    public static void testMethods(){
        system.debug('value before'+isflag);
        isflag=true;
        system.debug('value after'+isflag);
    }
}