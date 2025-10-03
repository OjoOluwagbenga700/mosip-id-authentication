package io.mosip.authentication.common.service.websub;

import java.util.function.Supplier;

/**
 * The Interface WebSubEventSubcriber.
 * @author Loganathan Sekar
 */
public interface WebSubEventSubcriber {
	
	/**
	 * subscribe.
	 *
	 * @param enableTester the enable tester
	 */
	void subscribe(Supplier<Boolean> enableTester);
	
}
