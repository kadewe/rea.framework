package Interfaces
{
	/**
	 * This interface helps to generalize objects, for example stored runtime in an array or so, to call the very helpful
	 * <code>removeAllEventListeners</code> function.
	 * 
	 * <p>It is required to extends Shared.EventDispatcher to implement this interface</p>
	 */
	public interface ICustomEventDispatcher
	{
		function removeAllEventListeners(type:String = ''):void;
	}
}