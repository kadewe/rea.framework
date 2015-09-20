/*

"Rich E-Assesment (REA) Framework"
A software framework for the use within the domain of e-assessment.

Copyright (C) 2014  University of Bremen, 
Working Group education media | media education 

Prof. Dr. Karsten Wolf, wolf@uni-bremen.de
Dipl.-Päd. Ilka Koppel, ikoppel@uni-bremen.de
Dipl.-Math. Kai Schwedes, kais@zait.uni-bremen.de
B.Sc. Jan Küster, jank87@tzi.de

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/
package utils
{
	import flash.geom.Point;
	
	import mx.core.ILayoutElement;
	
	import spark.components.supportClasses.GroupBase;
	import spark.layouts.VerticalAlign;
	import spark.layouts.supportClasses.LayoutBase;
	
	/**
	 * Lays out elements the same way as text area positions words: putting them in
	 * one line and going to next line when there is no space for new word.
	 * 
	 * copyright: Maxim Kachurovskiy
	 * http://cookbooks.adobe.com/post_Horizontal_Multiline_Layout-17807.html
	 * 
	 * <p>Code is modified by Jan Kuester <code>jank87(at)tzi(dot)de</code>, University of Bremen, Bremen Germany</p>
	 * <p>Modification: Layout-in-Row --> Text can be aligned into middle, top or bottom align in each line,
	 * Text can be aligned by the measurements of a source element (e.g. an image) in each line, Text can be aligned by a fixed
	 * pixel value in each line.</p>
	 */
	public class HorizontalMultilineLayout extends LayoutBase
	{
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		private var lastWidth:Number = -1;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  horizontalGap
		//----------------------------------
		
		private var _horizontalGap:Number = 6;
		
		public function get horizontalGap():Number
		{
			return _horizontalGap;
		}
		
		public function set horizontalGap(value:Number):void
		{
			if (value == _horizontalGap)
				return;
			
			_horizontalGap = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		//----------------------------------
		//  verticalGap
		//----------------------------------
		
		private var _verticalGap:Number = 6;
		
		public function get verticalGap():Number
		{
			return _verticalGap;
		}
		
		public function set verticalGap(value:Number):void
		{
			if (value == _verticalGap)
				return;
			
			_verticalGap = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		//----------------------------------
		//  verticalAlign
		//----------------------------------
		
		private var _verticalAlign:String = VerticalAlign.BOTTOM;
		
		[Inspectable("General", enumeration="top,bottom,middle", defaultValue="bottom")]
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}
		
		public function set verticalAlign(value:String):void
		{
			if (_verticalAlign == value)
				return;
			
			_verticalAlign = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		//----------------------------------
		//  paddingLeft
		//----------------------------------
		
		private var _paddingLeft:Number = 0;
		
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			if (_paddingLeft == value)
				return;
			
			_paddingLeft = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		//----------------------------------
		//  paddingRight
		//----------------------------------
		
		private var _paddingRight:Number = 0;
		
		public function get paddingRight():Number
		{
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			if (_paddingRight == value)
				return;
			
			_paddingRight = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		//----------------------------------
		//  paddingTop
		//----------------------------------
		
		private var _paddingTop:Number = 0;
		
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			if (_paddingTop == value)
				return;
			
			_paddingTop = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		//----------------------------------
		//  paddingBottom
		//----------------------------------
		
		private var _paddingBottom:Number = 0;
		
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			if (_paddingBottom == value)
				return;
			
			_paddingBottom = value;
			invalidateTargetSizeAndDisplayList();
		}    
		
		//----------------------------------
		// Vertical Layout in each Row
		//----------------------------------
		
		private var _verticalLayoutInLine:String=VerticalAlign.MIDDLE;
		
		public function get verticalLayoutInLine():String
		{
			return _verticalLayoutInLine;
		}
		
		public function set verticalLayoutInLine(value:String):void
		{
			if (_verticalLayoutInLine == value)
				return;
			
			_verticalLayoutInLine = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		
		//----------------------------------
		// Source Element for LineHeight
		//----------------------------------
		
		private var _lineHeightSource:ILayoutElement=null;
		
		public function get lineHeightSource():ILayoutElement
		{
			return _lineHeightSource;
		}
		
		public function set lineHeightSource(value:ILayoutElement):void
		{
			if (_lineHeightSource == value)
				return;
			
			_lineHeightSource = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		//----------------------------------
		// Manual Line Height in pixel
		//----------------------------------
		
		private var _lineHeightInPixel:Number = 0;
		
		public function get lineHeightInPixel():Number
		{
			return _lineHeightInPixel;
		}
		
		public function set lineHeightInPixel(value:Number):void
		{
			if (_lineHeightInPixel == value)
				return;
			
			_lineHeightInPixel = value;
			invalidateTargetSizeAndDisplayList();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Overriden methods
		//
		//--------------------------------------------------------------------------
		
		override public function measure():void
		{
			if (lastWidth == -1)
				return;
			
			var measuredWidth:Number = 0;
			var measuredMinWidth:Number = 0;
			var measuredHeight:Number = 0;
			var measuredMinHeight:Number = 0;
			
			var layoutTarget:GroupBase = target;
			var n:int = layoutTarget.numElements;
			var element:ILayoutElement;
			var i:int;
			var width:Number = layoutTarget.explicitWidth;
			if (isNaN(width) && lastWidth != -1)
				width = lastWidth;
			if (isNaN(width)) // width is not defined by parent or user
			{
				// do not specify measuredWidth and measuredHeight to real
				// values because in fact we can layout at any width or height
				for (i = 0; i < n; i++)
				{
					element = layoutTarget.getElementAt(i);
					if (!element || !element.includeInLayout)
						continue;
					
					measuredWidth = Math.ceil(element.getPreferredBoundsWidth());
					measuredHeight = Math.ceil(element.getPreferredBoundsHeight());
					break;
				}
				measuredMinWidth = measuredWidth;
				measuredMinHeight = measuredHeight;
			}
			else
			{
				// calculate lines based on width
				var currentLineWidth:Number = 0;
				var currentLineHeight:Number = 0;
				var lineNum:int = 1;
				for (i = 0; i < n; i++)
				{
					element = layoutTarget.getElementAt(i);
					if (!element || !element.includeInLayout)
						continue;
					
					var widthWithoutPaddings:Number = width - _paddingLeft - _paddingRight;
					var elementWidth:Number = Math.ceil(element.getPreferredBoundsWidth());
					if (currentLineWidth == 0 || 
						currentLineWidth + _horizontalGap + elementWidth <= widthWithoutPaddings)
					{
						currentLineWidth += elementWidth + (currentLineWidth == 0 ? 0 : _horizontalGap);
						currentLineHeight = Math.max(currentLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
					}
					else
					{
						measuredHeight += currentLineHeight;
						
						lineNum++;
						currentLineWidth = elementWidth;
						currentLineHeight = Math.ceil(element.getPreferredBoundsHeight());
					}
				}
				measuredHeight += currentLineHeight;
				if (lineNum > 1)
					measuredHeight += _verticalGap * (lineNum - 1);
				
				// do not set measuredWidth to real value because really we can  
				// layout at any width
				for (i = 0; i < n; i++)
				{
					element = layoutTarget.getElementAt(i);
					if (!element || !element.includeInLayout)
						continue;
					
					measuredWidth =
						measuredMinWidth = Math.ceil(element.getPreferredBoundsWidth());
					break;
				}
				measuredMinHeight = measuredHeight;
			}
			
			layoutTarget.measuredWidth = measuredWidth + _paddingLeft + _paddingRight;
			layoutTarget.measuredMinWidth = measuredMinWidth + _paddingLeft + _paddingRight;
			layoutTarget.measuredHeight = measuredHeight + _paddingTop + _paddingBottom;
			layoutTarget.measuredMinHeight = measuredMinHeight + _paddingTop + _paddingBottom;
		}
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			var layoutTarget:GroupBase = target;
			var n:int = layoutTarget.numElements;
			var element:ILayoutElement;
			var i:int;
			// calculate lines based on width
			var x:Number = _paddingLeft;
			var y:Number = _paddingTop;
			var maxLineHeight:Number = 0;
			var elementCounter:int = 0;
			var positions:Vector.<Point> = new Vector.<Point>();
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				
				var elementWidth:Number = Math.ceil(element.getPreferredBoundsWidth());
				if (x == _paddingLeft || 
					x + _horizontalGap + elementWidth <= width - _paddingRight)
				{
					if (elementCounter > 0)
						x += _horizontalGap;
					positions[i] = new Point(x, y);
					element.setLayoutBoundsSize(NaN, NaN);
					maxLineHeight = Math.max(maxLineHeight, Math.ceil(element.getPreferredBoundsHeight()));
				}
				else
				{
					x = _paddingLeft;
					y += _verticalGap + maxLineHeight;
					maxLineHeight = Math.ceil(element.getPreferredBoundsHeight());
					positions[i] = new Point(x, y);
					element.setLayoutBoundsSize(NaN, NaN);
				}
				x += elementWidth;
				elementCounter++;
				if(_lineHeightSource!=null)
					maxLineHeight = _lineHeightSource.getPreferredBoundsHeight();
				if(_lineHeightInPixel!=0)
					maxLineHeight = _lineHeightInPixel;
			}
			

			// verticalAlign and setLayoutBoundsPosition() for elements
			var yAdd:Number = 0;
			var yDifference:Number = height - (y + maxLineHeight + _paddingBottom);
			if (_verticalAlign == VerticalAlign.MIDDLE)
			{
				yAdd = Math.round(yDifference / 2);
			}else if (_verticalAlign == VerticalAlign.BOTTOM){
				
				yAdd = Math.round(yDifference);
			}
			
			
			for (i = 0; i < n; i++)
			{
				element = layoutTarget.getElementAt(i);
				if (!element || !element.includeInLayout)
					continue;
				var yh:Number  = _verticalLayoutInLine==VerticalAlign.MIDDLE?(maxLineHeight - element.getPreferredBoundsHeight())/2:_verticalLayoutInLine==VerticalAlign.BOTTOM?maxLineHeight - element.getPreferredBoundsHeight():0;
				var point:Point = positions[i];
				point.y += (yAdd+yh);
				element.setLayoutBoundsPosition(point.x, point.y);
			}
			
			// if width changed then height will change too - remeasure
			if (lastWidth == -1 || lastWidth != width)
			{
				lastWidth = width;
				invalidateTargetSizeAndDisplayList();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		private function invalidateTargetSizeAndDisplayList():void
		{
			var g:GroupBase = target;
			if (!g)
				return;
			
			g.invalidateSize();
			g.invalidateDisplayList();
		}
		
	}
}