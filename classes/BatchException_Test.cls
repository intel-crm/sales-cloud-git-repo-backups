@istest
public class BatchException_Test
{
// This test method can throw private exception defined in another class
static testmethod void test2() {
// Throw private exception.
try {
throw new BatchException('Thrown from a test.');
} catch(BatchException e) {
// Handle exception
e.ForTestClass();
}
}
}