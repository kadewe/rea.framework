package Interfaces
{
	
	/**
	 * This interface is for accessing information of any selectable component. These components are generally used within questions. It allows the program to iterate the references and look for already selected Objects.
	 * Instead of overwriting the synchronize() function in each new question class, you just have to assure it implements this interface.
	 * 
	 * <p>By using this, it is possible to implement a radio button or check box behavior for an image or other visual components, without extending these classes</p>
	 */
	public interface ICustomSelectable
	{	
		function get selected():Boolean;
		function set selected(value:Boolean):void;
	}
}