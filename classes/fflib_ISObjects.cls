public interface fflib_ISObjects extends fflib_IObjects
{
	/**
	 * @return Return the SObject records contained in the domain
	 */
	List<SObject> getRecords();

	/**
	 * @return Return the SObject records ids contained in the domain
	 */
	Set<Id> getRecordIds();

	/**
	 * @return Return the SObjectType of the SObjects contained in the domain
	 */
	SObjectType getSObjectType();
}