public class LazyFilterIterator extends LazyIterator {
    private BooleanFunction matchingFunction;
    private Object peek;
    private Boolean peekIsValid;

    public LazyFilterIterator(Iterator<Object> iterator, BooleanFunction matchingFunction) {
        super(iterator);
        this.matchingFunction = matchingFunction;
        this.peekIsValid = false;
    }

    private void peek() {
        if(iterator.hasNext()) {
            peek = iterator.next();
            peekIsValid = true;
        } else {
            peekIsValid = false;
        }
    }

    public override Boolean hasNext() {
        if (!peekIsValid) {
            peek();
        }
        while(peekIsValid) {
            if(matchingFunction.isTrueFor(peek)) {
                return true;
            } else {
                peek();
            }
        }
        return false;
    }

    public override Object next() {
        if(hasNext()) {
            peekIsValid = false;
            return peek;
        } else {
            throw new NoSuchElementException();
        }
    }
}