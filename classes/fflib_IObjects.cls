public interface fflib_IObjects extends fflib_IDomain
{
	/**
	 * @param value Values to check if they are part of the domain
	 *
	 * @return True if the provided value is part of the domain
	 */
	Boolean contains(Object value);

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are part of the domain
	 */
	Boolean containsAll(List<Object> values);

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are part of the domain
	 */
	Boolean containsAll(Set<Object> values);

	/**
	 * @param value Value to check if it is part of the domain
	 *
	 * @return True if the provided value is not part of the domain
	 */
	Boolean containsNot(Object value);

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are not part of the domain
	 */
	Boolean containsNot(List<Object> values);

	/**
	 * @param values Values to check if they are part of the domain
	 *
	 * @return True if all the provided values are not part of the domain
	 */
	Boolean containsNot(Set<Object> values);

	/**
	 * @return Returns True is the domain is empty
	 */
	Boolean isEmpty();

	/**
	 * @return Returns True is the domain has objects
	 */
	Boolean isNotEmpty();

	/**
	 * @return Returns the amount of records contained in the domain
	 */
	Integer size();
}