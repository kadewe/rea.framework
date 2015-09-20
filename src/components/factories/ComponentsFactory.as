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
package components.factories
{
	import components.BasicSoundButton;
	import components.ReaButton;
	import components.ReaImage;
	import components.SelectableImage;
	import components.SkinnedComponents.BackButton;
	import components.SkinnedComponents.CustomTextInput;
	import components.SkinnedComponents.ForwardButton;
	import components.SkinnedComponents.HelpButton;
	import components.SkinnedComponents.MiniSoundButton;
	import components.SkinnedComponents.SmallEyeButton;
	import components.SkinnedComponents.SmallSoundButton;
	import components.SkinnedComponents.SoundButton;
	
	import flash.events.MouseEvent;
	
	import interfaces.IClickable;
	
	import models.Globals;
	
	import mx.graphics.SolidColorStroke;
	
	import org.osmf.layout.ScaleMode;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Line;
	
	import utils.MP3Audio;
	import utils.ReaVisualUtils;

	/**
	 * A simple factory to create some generic components.
	 */
	public class ComponentsFactory
	{
		
		/**
		 * @private
		 */
		private static var _scriptUrl:String="";
		
		/**
		 * The url to the public php script on the server 
		 */
		public static function set scriptUrl(value:String):void
		{
			_scriptUrl = value || "";
		}
		
		//------------------------------------------------------------------------------
		//
		//	BUTTONS
		//
		//------------------------------------------------------------------------------
		
		// ----------------- standard Buttons ------------------- //
		
		/**
		 * Creates a new CustomButton as IClickableComponent
		 * 
		 * @param id The id of the button
		 * @param refObj Deprecated. The object which is kept as a sound reference. Use SoundButton instead.
		 */
		public static function createCustomButton(id:String,refObj:Object=null):IClickable
		{
			var cb:ReaButton = new ReaButton();
				cb.referringTo = refObj;
				cb.id = id;
			return cb;
		}
		
		/**
		 * Creates a button which has a reading icon as IClickableComponent
		 * 
		 * @param eyeBtnId The id of the button
		 * @param visibleRef Keeps a reference to an object which may become visible. See also VisibleList class
		 */
		public static function createSmallEyeButton(eyeBtnId:String,visibleRef:Object=null):IClickable
		{
			var sebtn:SmallEyeButton = new SmallEyeButton();
				sebtn.visibleReference = visibleRef;
				sebtn.id = eyeBtnId;
				sebtn.visibleReference = visibleRef;
			return sebtn;
		}
		
		
		/**
		 * Creates a Helpbutton with a default ? symbol as IClickableComponent.
		 * 
		 * @param id the id of the button
		 * @param label The label 
		 */
		public static function createHelpButton(id:String,label:String):IClickable
		{
			var help:HelpButton = new HelpButton();
				help.id = id;
				if(!label || label.length==0)help.label = "?";
				else help.label = label;	
				help.styleName = "helpButton";
			return help;
		}
		
		/**
		 * Creates a StartButton as IClickableComponent
		 * @id the id of the button
		 * @label The label 
		 */
		public static function createStartButton(id:String, label:String):IClickable
		{
			var c:ReaButton = new ReaButton();
				c.id = id;
				c.label = label || Globals.instance().returnLabelValue("startButton");
				c.styleName = "startButton";
				return c;
		}
		
		
		/**
		 * Creates a ForWardButton as IClickableComponent
		 * @id the id of the button
		 * @label The label 
		 * @styleName The stylename of the component, default is "fowardButton"
		 */
		public static function createForwardButton(id:String,label:String,styleName:String):IClickable
		{
			var f:ForwardButton = new ForwardButton();
				f.id=id;
				f.label = label || Globals.instance().returnLabelValue("forwardButton");
				f.styleName = "forwardButton";
			return f;
		}
		
		
		/**
		 * Creates a ForWardButton as IClickableComponent
		 * @id the id of the button
		 * @label The label 
		 * @refObj The object which is reffered to by click
		 */
		public static function backButton(id:String=null, label:String=null, refObj:Object = null):IClickable
		{
			var bb:BackButton = new BackButton();
				bb.id = id || "backButton";
				bb.label = label || Globals.instance().returnLabelValue("backButton");
				bb.referringTo = refObj;
				bb.styleName = "backButton";
			return bb;
		}
		
		
		/**
		 * 
		 */
		public static function noButton(id:String=null, label:String=null):IClickable
		{
			var no:BasicSoundButton = new BasicSoundButton();
				no.playHover = true;
				no.scriptUrl = _scriptUrl;
				no.id = id || "noButton";
				no.source = Globals.instance().returnSoundUrl("noButton");
				no.label = label || Globals.instance().returnLabelValue("noButton");
				return no;
		}
		
		
		/**
		 * 
		 */
		public static function endButton(id:String=null, label:String=null):IClickable
		{
			var end:BasicSoundButton = new BasicSoundButton();
				end.playHover = true;
				end.scriptUrl = _scriptUrl;
				end.id = id || "endButton";
				end.source = Globals.instance().returnSoundUrl("mainAppEndButton");
				end.label = label || Globals.instance().returnLabelValue("mainAppEndButton");
				
				return end;
		}
		
		
		// ----------------- sound Buttons ------------------- //
		
		/**
		 * 
		 */
		public static function createBasicSoundButton(label:String,scriptUrl:String, source:String, playHover:Boolean, playClick:Boolean,referingTo:Object=null, visibleRef:Object=null ):IClickable
		{
			var bs:BasicSoundButton = new BasicSoundButton();
				bs.label = label;
				bs.scriptUrl = scriptUrl;
				bs.playClick = playClick;
				bs.playHover = playHover;
				bs.visibleReference = visibleRef;
				bs.referringTo = referingTo;
				bs.source = source;
				bs.styleName = "";
			return bs;
		}
		
		
		/**
		 * 
		 */
		public static function createSoundButton(scriptUrl:String,relUrl:String,soundID:String,soundBtnId:String,visibleRef:Object=null):IClickable
		{
			
			var sbtn:SoundButton = new SoundButton();
			var snd:MP3Audio = new MP3Audio(scriptUrl,relUrl,soundID);
				snd.parent = sbtn;
				sbtn.referringTo = snd;
				sbtn.id = soundBtnId;
				sbtn.visibleReference = visibleRef;
				sbtn.addEventListener(MouseEvent.CLICK, snd.playAudio);
			return sbtn;
		}
		
		
		/**
		 * 
		 */
		public static function createSmallSoundButton(scriptUrl:String,relUrl:String,soundID:String,soundBtnId:String,visibleRef:Object=null):IClickable
		{
		
			var ssbtn:SmallSoundButton = new SmallSoundButton();
			var snd:MP3Audio = new MP3Audio(scriptUrl,relUrl,soundID);
				snd.parent = ssbtn;
				ssbtn.referringTo = snd;
				ssbtn.id = soundBtnId;
				ssbtn.visibleReference = visibleRef;
				ssbtn.addEventListener(MouseEvent.CLICK, snd.playAudio);
			return ssbtn;
			
		}
		
		
		/**
		 * 
		 * 
		 */
		public static function createMiniSoundButton(scriptUrl:String,relUrl:String,soundID:String,soundBtnId:String,visibleRef:Object=null):IClickable
		{
			
			var ssbtn:MiniSoundButton = new MiniSoundButton();
			var snd:MP3Audio = new MP3Audio(scriptUrl,relUrl,soundID);
				snd.parent = ssbtn;
				ssbtn.referringTo = snd;
				ssbtn.id = soundBtnId;
				ssbtn.visibleReference = visibleRef;
				ssbtn.addEventListener(MouseEvent.CLICK, snd.playAudio);
			return ssbtn;
			
		}
		

		//------------------------------------------------------------------------------
		//
		//	TEXT COMPONENTS
		//
		//------------------------------------------------------------------------------
		
		// ------------------- LABELS ------------------- //
		
		
		/***
		 * 
		 */
		public static function createLabe(text:String,id:String, styleName:String = "Text-22",maxW:Number=undefined,maxH:Number=undefined):Label
		{
			var l:Label = new Label();
				l.id = id;
				l.percentWidth = maxW || 100;
				l.text = text;
				styleName = styleName==null || styleName == "" ? Globals.TEXT_STANDARD : styleName;	//FALLBACK
				l.styleName = styleName;
			return l;
		}
		
		
		/**
		 * 
		 */
		public static function createLabelFromXMLNode(node:XML,id:String,maxW:Number=undefined,maxH:Number=undefined):Label
		{
			var l:Label = new Label();
				l.id = id;
				l.explicitMaxWidth=maxW;
				l.text = node.children().toString();
				l.styleName = node.@cssstyle.length()>0?ReaVisualUtils.convertToString(node.@cssstyle):"Text-22";
			return l;
		}
		
		
		/**
		 * 
		 * 
		 */
		public static function createCustomTextInput(id:String="",lineLength:Number=0,text:String="",maxChars:uint=0,styleName:String="",enableAutoResize:Boolean=true):CustomTextInput
		{
			//initial values
			var lineWidth:Number = lineLength;
			var cti:CustomTextInput = new CustomTextInput();
				cti.id = id.length>0?id:"custom_text_input_"+String(Math.random()*1000);
				cti.styleName = styleName.length>0?styleName:"TextInput_default";
				cti.text = text;
				cti.maxChars=(maxChars>0)?maxChars:(text.length>0)?text.length:5;
				cti.height=33;
				
				//sizing
				cti.setAutoResizeEnabled(enableAutoResize);
				cti.setLineWidth(lineLength);
				cti.initMeasure();

			
			return cti;
		}
		
		
		//------------------------------------------------------------------------------
		//
		//	CONTAINERS
		//
		//------------------------------------------------------------------------------
		

		/**
		 * 
		 */
		public static function createGroup(id:String,layout:LayoutBase,maxW:Number=undefined,maxH:Number=undefined):Group
		{
			var g:Group=new Group();
				g.id = id;
				g.layout = layout;
				g.explicitMaxWidth=maxW;
				g.explicitMaxHeight=maxH;
			return g;
		}
		
		
		/**
		 * 
		 */
		public static function createHGroup(id:String,halign:String="center",valign:String="top",maxW:Number=undefined,maxH:Number=undefined):HGroup
		{
			var hg:HGroup = new HGroup();
				hg.id = id;

				hg.horizontalAlign = halign;
				hg.verticalAlign = valign;
			return hg;
		}
		
		
		/**
		 * 
		 */
		public static function createVGroup(id:String,halign:String="center",valign:String="top",maxW:Number=undefined,maxH:Number=undefined):VGroup
		{
			var vg:VGroup = new VGroup();
				vg.id = id;
				vg.explicitMaxWidth = maxW;
				vg.explicitMaxHeight=maxH;
				vg.horizontalAlign = halign;
				vg.verticalAlign = valign;
			return vg;
		}
		
		//------------------------------------------------------------------------------
		//
		//	LAYOUTS
		//
		//------------------------------------------------------------------------------
		
		
		/**
		 * 
		 */
		public static function createHorizontalLayout(vert:String="middle",hori:String="center",gap:int=10):HorizontalLayout
		{
			var lay:HorizontalLayout = new HorizontalLayout();
				lay.verticalAlign = vert;
				lay.horizontalAlign= hori;
				lay.gap = gap;
			return lay;
		}
		
		
		/**
		 * 
		 */
		public static function createVerticalLayout(vert:String="middle",hori:String="center",gap:int=10):VerticalLayout
		{
			var lay:VerticalLayout = new VerticalLayout();
				lay.verticalAlign = vert;
				lay.horizontalAlign= hori;
				lay.gap = gap;
			return lay;
		}
		
		//------------------------------------------------------------------------------
		//
		//	IMAGE
		//
		//------------------------------------------------------------------------------
		
		
		/**
		 * 
		 */
		public static function createCustomImage(id:String,scriptUrl:String,relUrl:String,percWidth:Number=100,percHeight:Number=100):ReaImage
		{
			var ci:ReaImage = new ReaImage(scriptUrl,relUrl);
				ci.id = id;
				ci.scaleMode = ScaleMode.LETTERBOX;
				ci.percentHeight = percWidth;
				ci.percentWidth = percHeight;
				ci.smooth = true;
			return ci;
		}
		
		/**
		 * 
		 */
		public static function createCustomSelectableImage(id:String,scriptUrl:String,relUrl:String,maxW:Number=undefined,maxH:Number=undefined):SelectableImage
		{
			var si:SelectableImage = new SelectableImage(scriptUrl, relUrl);
				si.id = id;
				si.id = id;
				si.maxWidth = maxW;
				si.maxHeight= maxH;
				si.smooth=true;
			return si;
		}
		
		
		//------------------------------------------------------------------------------
		//
		//	Graphics
		//
		//------------------------------------------------------------------------------
		
		/**
		 * Creates a line as separator between elements. Horizontal or vertical is indicated by height and width. If percentwidth / percentheight are passed, width and height are ignored.
		 */
		public static function createLine(width:Number=0, height:Number=0,weight:int=2,alph:Number=0.2,col:uint=0x000000, percentWidth:int=0,percentHeight:int=0):Line
		{
			var ln:Line = new Line();
			var sc:SolidColorStroke = new SolidColorStroke();
				sc.color=col;
				sc.weight=weight;
				sc.alpha=alph;
				sc.joints="BEVEL";
			ln.stroke =sc;
			if(percentWidth > 0)
				ln.percentWidth = percentWidth;
			else
				ln.width = width;
			if(percentHeight > 0)
				ln.percentHeight = percentHeight;
			else
				ln.height = height;
			
			return ln;
		}
		
		/**
		 * Creates a group with an upper term, a separator and a lower term alltogether representing a fraction.
		 * 
		 * @param top upper value
		 * @param bottom lower value
		 * @param fract_id id of the component
		 * @param styleName css style of the font
		 * @param size	used for calculation of the text size
		 * 
		 * @return VGRoup - a vertical group with two labels and a line.
		 */
		public static function createFractionComponent(top:Number, bottom:Number,fract_id:String,styleName:String="Text-22",size:int=22):VGroup
		{
			//TOP
			var ltop:Label = createLabe(top.toString(),fract_id+"_ltop",styleName);

			//BOTTOM
			var lbot:Label = createLabe(bottom.toString(),fract_id+"_lbottom",styleName);

			
			//get line width
			var maxw:Number = (ltop.text.length*size) >(lbot.text.length*size) ? (ltop.text.length*size) : (lbot.text.length*size);
			
			//LINE
			var l:Line = createLine(maxw,0,2,0.4,0x000000,100);
				l.id = fract_id + "_line";
			
			//VGrouop
			var v:VGroup = createVGroup(fract_id+"_vgroup","center","middle");
				v.gap = 5;
				v.addElement(ltop);
				v.addElement(l);
				v.addElement(lbot);
			return v;
		}
	}
}