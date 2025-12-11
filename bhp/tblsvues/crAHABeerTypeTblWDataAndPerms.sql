use [BHP1-RO]
go

begin try
	drop table [bhp].AHABeerStyle;
	print 'table:[[bhp].AHABeerStyle] dropped!!!';
end try
begin catch
	print 'Table:[[bhp].AHABeerStyle] doesn''t exist...';
end catch
go

create table [bhp].AHABeerStyle (
	RowID int identity(1,1) not null,
	CategoryName nvarchar(200) not null,
	Name nvarchar(100) not null,
	Descr nvarchar(4000) not null,
	[Lang] nvarchar(20) null,
	EnteredOn datetime null,
	Constraint [PK_AHABeerStyle_RowID] Primary Key NonClustered(RowID)
)
go

print 'Table:[[bhp].AHABeerStyle] created...';
go

alter table [bhp].[AHABeerStyle] add
constraint [DF_AHABeerStyle_Lang] default(N'en_us') for [Lang],
Constraint [DF_AHABeerStyle_EnteredOn] default(getdate()) for [EnteredOn];
go

create unique clustered index IDX_AHABeerStyle_Name on [bhp].AHABeerStyle (CategoryName, Name);
go

set identity_insert [bhp].AHABeerStyle on;
insert into [bhp].AHABeerStyle(RowID,CategoryName,Name,Descr) values(0,'Undef','Undef','do not remove!!!');
insert into [bhp].AHABeerStyle(RowID,CategoryName,Name,Descr) values(1,'By Request','Customer Choice','customer chooses the name of beer');
set identity_insert [bhp].AHABeerStyle off;
go

insert into [bhp].AHABeerStyle(CategoryName,Name,Descr)
values
( 'Barley Wine','English-Style','English-style barley wines range from tawny copper to dark brown in color and have a full body and high residual malty sweetness. Complexity of alcohols and fruity-ester characters are often high and counterbalanced by the perception of low to assertive bitterness and extraordinary alcohol content. Hop aroma and flavor may be minimal to very high. Low levels of diacetyl may be acceptable. A caramel and vinous (sometimes sherrylike) aroma and flavor are part of the character. Chill haze is allowable at cold temperatures.')
,
( 'Barley Wine','American-Style','American-style barley wines range from tawny copper to dark brown in color and have a full body and high residual malty sweetness. Complexity of alcohols and fruity-ester characters are often high and counterbalanced by the perception of medium to assertive bitterness and extraordinary alcohol content. Hop aroma and flavor may be medium to very high. Low levels of diacetyl may be acceptable. A caramel and vinous (sometimes sherrylike) aroma and flavor are part of the character. Chill haze is allowable at cold temperatures.')
,
( 'Belgian & French Ale','Flander Brown/Ouid Bruin','This light- to medium-bodied deep copper to brown ale is characterized by a slight to strong vinegar or lactic sourness and spiciness. A fruityestery character is apparent with no hop flavor or aroma. Flanders brown ales have low to medium bitterness. Very small quantities of diacetyl are acceptable. Roasted malt character in aroma and flavor is acceptable at low levels. Oaklike or woody characters may be pleasantly integrated into overall palate. Chill haze is acceptable at low serving temperatures. Some versions may be more highly carbonated and, when bottle conditioned, may appear cloudy (yeast) when served.')
,
( 'Belgian & French Ale','Dubbel','This medium- to full-bodied, dark amber to brown-colored ale has a malty sweetness and nutty, chocolate-like, and roast malt aroma. A faint hop aroma is acceptable. Dubbels are also characterized by low bitterness and no hop flavor. Very small quantities of diacetyl are acceptable. Yeast-generated fruity esters (especially banana) are appropriate at low levels. Head retention is dense and mousselike. Chill haze is acceptable at low serving temperatures.')
,
( 'Belgian & French Ale','Tripel','Tripels are often characterized by a complex, spicy, phenolic flavor. Yeast-generated fruity banana esters are also common, but not necessary. These pale/lightcolored ales usually finish sweet. The beer is characteristically medium to full bodied with a neutral hop/malt balance. Its sweetness will come from very pale malts. There should not be character from any roasted or dark malts. Low hop flavor is okay. Alcohol strength and flavor should be perceived as evident. Head retention is dense and mousselike. Chill haze is acceptable at low serving temperatures.')
,
( 'Belgian & French Ale','Belgian Pale Ale','Belgian-style pale ales are characterized by low, but noticeable, hop bitterness, flavor, and aroma. Light to medium body and low malt aroma are typical. They are golden to deep amber in color. Noble-type hops are commonly used. Low to medium fruity esters are evident in aroma and flavor. Low caramel or toasted malt flavor is okay. Diacetyl should not be perceived. Chill haze is allowable at cold temperatures.')
,
( 'Belgian & French Ale','Belgian Pale Strong Ale','Belgian pale strong ales are pale to golden in color with relatively light body for a beer of its alcoholic strength. Often brewed with light colored Belgian "candy" sugar, these beers are well attenuated. The perception of hop bitterness is low to medium, with hop flavor and aroma also in this range. These beers are highly attenuated and have a perceptively deceiving high alcoholic character?being light to medium bodied rather than full bodied. The intensity of malt character should be low to medium, often surviving along with a complex fruitiness. Very little or no diacetyl is perceived. Herbs and spices are sometimes used to delicately flavor these strong ales. Chill haze is allowable at cold temperatures.')
,
( 'Belgian & French Ale','Dark Strong Ale','Belgian dark strong ales are amber to dark brown in color. Often, though not always, brewed with dark Belgian "candy" sugar, these beers can be well attenuated, though medium to full bodied. The perception of hop bitterness is low to medium, with hop flavor and aroma also in this range. Fruity complexity along with the soft flavors of roasted malts add distinct character. The alcohol strength of these beers can often be deceiving to the senses. The intensity of malt character can be rich, creamy, and sweet with intensities ranging from medium to high. Very little or no diacetyl is perceived. Herbs and spices are sometimes used to delicately flavor these strong ales. Chill haze is allowable at cold temperatures.')
,
( 'Belgian & French Ale','White (Wit)','Belgian white ales are brewed using unmalted wheat and malted barley and are spiced with coriander and orange peel. These very pale beers are often bottle conditioned and served cloudy. The style is further characterized by the use of noble-type hops to achieve a low to medium bitterness and hop flavor. This beer has low to medium body, no diacetyl, and a low to medium fruity-ester level. Mild acidity is appropriate.')
,
( 'Belgian & French Ale','Biere de Garde','Beers in this category are golden to deep copper or light brown in color. They are light to medium in body. This style of beer is characterized by a toasted malt aroma, slight malt sweetness in flavor, and medium hop bitterness. Noble-type hop aromas and flavors should be low to medium. Fruity esters can be light to medium in intensity. Flavor of alcohol is evident. Earthy, cellarlike, musty aromas are okay. Diacetyl should not be perceived but chill haze is okay. Often bottle conditioned with some yeast character.')
,
( 'Belgian Style Lambic','Lambic','Unblended, naturally and spontaneously fermented lambic is intensely estery, sour, and often, but not necessarily, acetic flavored. Low in carbon dioxide, these hazy beers are brewed with unmalted wheat and malted barley. Sweet malt characters are not perceived. They are very low in hop bitterness. Cloudiness is acceptable. These beers are quite dry and light bodied. Versions of this beer made outside of the Brussels area of Belgium cannot be true lambics. These versions are said to be "lambic-style" and may be made to resemble many of the beers of true origin.')
,
( 'Belgian Style Lambic','Gueuze Lambic','Old lambic is blended with newly fermenting young lambic to create this special style of lambic. Gueuze is always refermented in the bottle. These unflavored blended and secondary fermented lambic beers may be very dry or mildly sweet and are characterized by intense fruity-estery, sour, and acidic aromas and flavors. These pale beers are brewed with unmalted wheat, malted barley, and stale, aged hops. Sweet malt characters are not perceived. They are very low in hop bitterness. Diacetyl should be absent. Cloudiness is acceptable. These beers are quite dry and light bodied. Versions of this beer made outside of the Brussels area of Belgium cannot be true lambics. These versions are said to be "lambic-style" and may be made to resemble many of the beers of true origin.')
,
( 'Belgian Style Lambic','Fruit Lambic','These beers, also known by the names framboise, kriek, peche, cassis, etc., are characterized by fruit flavors and aromas. The color reflects the choice of fruit. Sourness is an important part of the flavor profile, though sweetness may compromise the intensity. These flavored lambic beers may be very dry or mildly sweet and range from a dry to a full-bodied mouthfeel. Versions of this beer made outside of the Brussels area of Belgium cannot be true lambics. These versions are said to be "lambic-style" and may be made to resemble many of the beers of true origin.')
,
( 'Mild and Brown Ale','English Light Mild','English pale mild ales range from light amber to light brown in color. Malty sweetness dominate the flavor profile with little hop bitterness or flavor. Hop aroma can be light. Very low diacetyl flavors may be appropriate in this low-alcohol beer. Fruity-ester level is very low. Chill haze is allowable at cold temperatures.')
,
( 'Mild and Brown Ale','English Dark Mild','English dark mild ales range from deep copper to dark brown (often with a red tint) in color. Malty sweetness and caramel are part of the flavor and aroma profile while, licorice and roast malt tones may sometimes contribute to the flavor and aroma profile. These beers have very little hop flavor or aroma. Very low diacetyl flavors may be appropriate in this low-alcohol beer. Fruity-ester level is very low.')
,
( 'Mild and Brown Ale','English Brown','English brown ales range from deep copper to brown in color. They have a medium body and a dry to sweet maltiness with very little hop flavor or aroma. Fruity-ester flavors are appropriate. Diacetyl should be very low, if evident. Chill haze is allowable at cold temperatures.')
,
( 'Mild and Brown Ale','American Brown','American brown ales range from deep copper to brown in color. Roasted malt caramellike and chocolatelike characters should be of medium intensity in both flavor and aroma. American brown ales have an evident hop aroma, medium to high hop bitterness, and a medium body. Estery and fruity-ester characters should be subdued; diacetyl should not be perceived. Chill haze is allowable at cold temperatures.')
,
( 'Mild and Brown Ale','Irish Red Ale','Irish-style red ales range from light red-amber-copper to light brown in color. These ales have a medium hop bitterness and flavor. They often don?t have hop aroma. Irish-style red ales have low to medium candy-like caramel sweetness and a medium body. The style may have low levels of fruity-ester flavor and aroma. Diacetyl should be absent. Chill haze is allowable at cold temperatures. Slight yeast haze is acceptable for bottle-conditioned products.')
,
( 'English Style Pale Ale','Classic','Classic English-style pale ales are golden to copper colored and display English-variety hop character. Medium to high hop bitterness, flavor, and aroma.')
,
( 'English Style Pale Ale','India Pale Ale','India pale ales are characterized by intense hop bitterness with a high alcohol content. Hops from a variety of origins are used to contribute to a high hopping rate. The use of water with high mineral content results in a crisp, dry beer. This pale gold to deep copper-colored ale has a full, flowery hop aroma and may have a strong hop flavor (in addition to the hop bitterness) . India pale ales possess medium maltiness and body. Fruity-ester flavors and aromas are moderate to very strong. Chill haze is allowable at cold temperatures.')
,
( 'American Style Ale','Pale Ale','American pale ales range from golden to light copper in color. The style is characterized by American-variety hops used to produce high hop bitterness, flavor and aroma. American pale ales have medium body and low to medium maltiness. Low caramel character is allowable. Fruity-ester flavor and aroma should be moderate to strong. Diacetyl should be absent or present at very low levels. Chill haze is allowable at cold temperatures.')
,
( 'American Style Ale','Amber Ale','American amber/red ales range from light copper to light brown in color. They are characterized by American-variety hops used to produce high hop bitterness, flavor, and aroma. Amber ales have medium-high to high maltiness with medium to low caramel character. They should have medium to medium-high body. The style may have low levels of fruity-ester flavor and aroma. Diacetyl can be either absent or barely perceived at very low levels. Chill haze is allowable at cold temperatures. Slight yeast haze is acceptable for bottle-conditioned products.')
,
( 'American Style Ale','Wheat','This beer can be made using either an ale or lager yeast. It can be brewed with 30 to 75 percent wheat, and hop rates may be low to medium. Fruity-ester aroma and flavor are typical but at low levels; however, phenolic, clovelike characteristics should not be perceived. Color is usually straw to light amber, and the body should be light to medium in character. Diacetyl should not be perceived. Yeast flavor and aroma should be low to medium but not overpowering the balance and character of malt and hops.')
,
( 'English Bitter','Ordinary Bitter','Ordinary bitter is gold to copper colored with medium bitterness, light to medium body, and low to medium residual malt sweetness. Hop flavor and aroma character may be evident at the brewer’s discretion. Mild carbonation traditionally characterize draft-cask versions, but in bottled versions, a slight increase in carbon dioxide content is acceptable. Fruity-ester character and very low diacetyl (butterscotch) character are acceptable in aroma and flavor, but should be minimized in this form of bitter. Chill haze is allowable at cold temperatures.')
,
( 'English Bitter','Special Bitter','Special bitter is more robust than ordinary bitter. It has medium body and medium residual malt sweetness. It is gold to copper colored with medium bitterness. Hop flavor and aroma character may be evident at the brewer?s discretion. Mild carbonation traditionally characterizes draft-cask versions, but in bottled versions, a slight increase in carbon dioxide content is acceptable. Fruity-ester character and very low diacetyl (butterscotch) character are acceptable in aroma and flavor. Chill haze is allowable at cold temperatures.')
,
( 'English Bitter','Extra Special Bitter','Extra special bitter possesses medium to strong hop qualities in aroma, flavor, and bitterness. The residual malt sweetness of this richly flavored, full-bodied bitter is more pronounced than in other bitters. It is gold to copper colored with medium bitterness. Mild carbonation traditionally characterizes draft-cask versions, but in bottled versions, a slight increase in carbon dioxide content is acceptable. Fruity-ester character and very low diacetyl (butterscotch) character are acceptable in aroma and flavor. Chill haze is allowable at cold temperatures.')
,
( 'Scottish Ale','Light','Scottish light ales are light bodied. Little bitterness is perceived and hop flavor or aroma should not be perceived. Despite its lightness, Scottish light ale will have a degree of malty, caramellike, soft and chewy character. Yeast characters such as diacetyl (butterscotch) and sulfuriness are acceptable at very low levels. The color will range from golden amber to deep brown and may sometimes possess a faint smoky character. Bottled versions of this traditional draft beer may contain higher amounts of carbon dioxide than is typical for mildly carbonated draft versions. Chill haze is acceptable at low temperatures.')
,
( 'Scottish Ale','Heavy','Scottish heavy ale is moderate in strength and dominated by a smooth, sweet maltiness balanced with low, but perceptible, hop bitterness. Hop flavor or aroma should not be perceived. Scottish heavy ale will have a medium degree of malty, caramellike, soft and chewy character in flavor and mouthfeel. It has medium body, and fruity esters are very low, if evident. Yeast characters such as diacetyl (butterscotch) and sulfuriness are acceptable at very low levels. The color will range from golden amber to deep brown and may sometimes possess a faint smoky character. Bottled versions of this traditional draft beer may contain higher amounts of carbon dioxide than is typical for draft versions. Chill haze is acceptable at low temperatures.')
,
( 'Scottish Ale','Export','The overriding character of Scottish export ale is sweet, caramellike, and malty. Its bitterness is perceived as low to medium. Hop flavor or aroma should not be perceived. It has medium body. Fruity-ester character may be apparent. Yeast characters such as diacetyl (butterscotch) and sulfuriness are acceptable at very low levels. The color will range from golden amber to deep brown and may sometimes possess a faint smoky character. Bottled versions of this traditional draft beer may contain higher amounts of carbon dioxide than is typical for mildly carbonated draft versions. Chill haze is acceptable at low temperatures.')
,
( 'Porter','Brown','Brown porters are mid to dark brown (may have red tint) in color. No roast barley or strong burnt malt character should be perceived. Low to medium malt sweetness is acceptable along with medium hop bitterness. This is a light- to medium-bodied beer. Fruity esters are acceptable. Hop flavor and aroma may vary from being negligible to medium in character.')
,
( 'Porter','Robust','Robust porters are black in color and have a roast malt flavor but no roast barley flavor. These porters have a sharp bitterness of black malt without a highly burnt/charcoal flavor. Robust porters range from medium to full in body and have a malty sweetness. Hop bitterness is medium to high, with hop aroma and flavor ranging from negligible to medium. Fruity esters should be evident, balanced with roast malt and hop bitterness.')
,
( 'English & Scottish Strong Ale','English Old Ale/Strong Ale','Amber to mid-range brown in color, English strong ales are medium to full bodied with a malty sweetness. Hop aroma should be minimal and flavor can vary from none to medium in character intensity. Fruity-ester flavors and aromas can contribute to the character of this ale. Bitterness should be minimal but evident and balanced with malt and/or caramellike sweetness. Alcohol types can be varied and complex. A distinctive quality of these ales is that they all undergo a prolonged aging process (often for years) on their yeast either in bulk storage or through conditioning in the bottle, which contributes to a rich, often sweet and complex estery character.')
,
( 'English & Scottish Strong Ale','Strong Scotch Ale','Scotch ales are overwhelmingly malty and full bodied. Perception of hop bitterness is very low. Hop flavor and aroma are very low or nonexistent. Color ranges from deep copper to brown. The clean alcohol flavor balances the rich and dominant sweet maltiness in flavor and aroma. A caramel character is often a part of the profile. Dark roasted malt flavors and aroma may be evident at low levels. Fruity esters are generally at medium aromatic and flavor levels. A peaty/smoky character may be evident at low levels. Low diacetyl levels are acceptable. Chill haze is allowable at cold temperatures.')
,
( 'Stout','Classic Irish-Style Dry','Dry stouts have an initial malt and caramel flavor profile with a distinctive dry-roasted bitterness in the finish. Dry stouts achieve a dry-roasted character through the use of roasted barley. Some slight acidity may be perceived but is not necessary. Hop aroma and flavor should not be perceived. Dry stouts have medium body. Fruity esters are minimal and overshadowed by malt, high hop bitterness, and roasted barley character. Diacetyl (butterscotch) should be very low or not perceived. Head retention and rich character should be part of its visual character.')
,
( 'Stout','Foreign Style','As with classic dry stouts, foreign-style stouts have an initial malt sweetness and caramel flavor with a distinctive dry-roasted bitterness in the finish. Some slight acidity is permissible and a medium- to full-bodied mouthfeel is appropriate. Bitterness may be high but the perception is often compromised by malt sweetness. Hop aroma and flavor should not be perceived. The perception of fruity esters is low. Diacetyl (butterscotch) should be negligible or not perceived. Head retention is excellent.')
,
( 'Stout','Sweet','Sweet stouts, also referred to as cream stouts, have less roasted bitter flavor and a full-bodied mouthfeel. The style can be given more body with milk sugar (lactose) before bottling. Malt sweetness, chocolate, and caramel flavor should dominate the flavor profile. Hops should balance sweetness without contributing apparent flavor or aroma.')
,
( 'Stout','Oatmeal','Oatmeal stouts include oatmeal in their grist, resulting in a pleasant, full flavor and a smooth profile that is rich without being grainy. A roasted malt character which is caramellike and chocolatelike should be evident ? smooth and not bitter. Bitterness is moderate, not high. Hop flavor and aroma are optional but should not overpower the overall balance if present. This is a medium- to full-bodied beer, with minimal fruity esters.')
,
( 'Stout','Imperial','Dark copper to very black, imperial stouts typically have a high alcohol content. The extremely rich malty flavor and aroma are balanced with assertive hopping and fruity-ester characteristics. Perceived bitterness can be moderate and balanced with the malt character or very high in the darker versions. Roasted malt astringency and bitterness can be moderately perceived but should not overwhelm the overall character. Hop aroma can be subtle to overwhelmingly floral. Diacetyl (butterscotch) levels should be very low.')
,
( 'Bock','Traditional','Traditional bocks are made with all malt and are strong, malty, medium- to full-bodied, bottom-fermented beers with moderate hop bitterness that should increase proportionately with the starting gravity. Hop flavor should be low and hop aroma should be very low. Bocks can range in color from deep copper to dark brown. Fruity esters may be perceived at low levels.')
,
( 'Bock','German-Style Helles Bock/Maibock','The German word helles means light colored, and as such, a helles bock is light straw to deep golden in color. Maibocks are also light-colored bocks. The malty character should come through in the aroma and flavor. Body is medium to full. Hop bitterness should be low, while noble-type hop aroma and flavor may be at low to medium levels. Bitterness increases with gravity. Fruity esters should be minimal. Diacetyl levels should be very low. Chill haze should not be perceived.')
,
( 'Bock','Doppelbock','Malty sweetness is dominant but should not be cloying. Doppelbocks are full bodied and deep amber to dark brown in color. Astringency from roast malts is absent. Alcoholic strength is high, and hop rates increase with gravity. Hop bitterness and flavor should be low and hop aroma absent. Fruity esters are commonly perceived but at low to moderate levels.')
,
( 'Bock','Eisbock','A stronger version of doppelbock. Malt character can be very sweet. The body is very full and deep copper to almost black in color. Alcoholic strength is very high. Hop bitterness is subdued. Hop flavor and aroma are absent. Fruity esters may be evident but not overpowering. Typically these beers are brewed by freezing a doppelbock and removing resulting ice to increase alcohol content.')
,
( 'German Dark Lager','Munich Dunkel','These light brown to dark brown beers have a pronounced malty aroma and flavor that dominates over the clean, crisp, moderate hop bitterness. A classic M?nchner dunkel should have a chocolatelike, roast malt, breadlike or biscuitlike aroma that comes from the use of Munich dark malt. Chocolate or roast malts can be used, but the percentage used should be minimal. Noble-type hop flavor and aroma should be low but perceptible. Diacetyl should not be perceived. Fruity esters and chill haze should not be perceived.')
,
( 'German Dark Lager','Schwarzbier','These very dark brown to almost black beers have a roasted malt character without the associated bitterness. Malt flavor and aroma are low in sweetness. Hop bitterness is low to medium in character. Noble-type hop flavor and aroma should be low but perceptible. There should be no fruity esters. Diacetyl is acceptable at very low levels.')
,
( 'Classic Pilsner','German Style','A classic German Pilsener is very light straw or golden in color and well hopped. Hop bitterness is high. Noble-type hop aroma and flavor are moderate and quite obvious. It is a well-attenuated, medium-bodied beer, but a malty residual sweetness can be perceived in aroma and flavor. Fruity esters and diacetyl should not be perceived. There should be no chill haze. Its head should be dense and rich.')
,
( 'Classic Pilsner','Bohemian Style','Bohemian Pilseners are slightly more medium bodied, and their color can be as dark as light amber. This style balances moderate bitterness and noble-type hop aroma and flavor with a malty, slightly sweet, medium body. Diacetyl may be perceived in very low amounts. There should be no chill haze. Its head should be dense and rich.')
,
( 'Classic Pilsner','American Style','This classic and unique pre-Prohibition American-style Pilsener is straw to deep gold in color. Hop bitterness, flavor and aroma are medium to high, and use of noble-type hops for flavor and aroma is preferred. Up to 25 percent corn in the grist should be used, and some slight sweetness and flavor of corn are expected. A low level of DMS is acceptable. Malt flavor and aroma are medium. This is a medium-bodied beer. Fruity esters and citrusy flavors or aromas should not be perceived. Slight diacetyl is acceptable. There should be no chill haze.')
,
( 'American Lager','American Lager','Light in body and color, American lagers are very clean and crisp and aggressively carbonated. Malt sweetness is absent. Corn, rice, or other grain or sugar adjuncts are often used. Hop aroma is absent. Hop bitterness is slight, and hop flavor is mild or negligible. Chill haze, fruity esters, and diacetyl should be absent.')
,
( 'American Lager','American style Light Lager','According to the United States FDA regulations, when used in reference to caloric content, "light" beers must have at least 25 percent fewer calories than the "regular" version of that beer. Such beers must have certain analysis data printed on the package label. These beers are extremely light colored, light in body, and high in carbonation. Flavor is mild and bitterness is very low. Chill haze, fruity esters, and diacetyl should be absent.')
,
( 'American Lager','American-Lager/Ale or Cream Ale','A mild, pale, light-bodied ale, made using a warm fermentation (top or bottom) and cold lagering or by blending top- and bottom-fermented beers. Hop bitterness and flavor range from very low to low. Hop aroma is often absent. Sometimes referred to as cream ales, these beers are crisp and refreshing. A fruity or estery aroma may be perceived. Diacetyl and chill haze should not perceived.')
,
( 'American Lager','American Premium','This style has low malt (and adjunct) sweetness, is medium bodied, and should contain no or a low percentage (less than 25%) of adjuncts. Color may be light straw to golden. Alcohol content and bitterness may also be greater. Hop aroma and flavor is low or negligible. Chill haze, fruity esters, and diacetyl should be absent.')
,
( 'American Lager','American Dark','This beer''s malt aroma and flavor are low but notable. Its color ranges from a very deep copper to a deep, dark brown. Its body is light. Non-malt adjuncts are often used, and hop rates are low. Hop bitterness, flavor, and aroma are low. Carbonation is high. Fruity esters, diacetyl, and chill haze should not be perceived.')
,
( 'German Light Lager','Muncher-Styule Helles','This beer has a relatively low bitterness. It is a medium-bodied, malt-emphasized beer; however, certain versions can approach a balance of hop character and maltiness. There should not be any caramel character. Color is light straw to golden. Fruity esters and diacetyl should not be perceived.')
,
( 'German Light Lager','Dortmunder/European-Style Export','Dortmunder has medium hop bitterness. Hop flavor and aroma are perceptible but low. Sweet malt flavor can be low and should not be caramellike. The color of this style is straw to deep golden. The body will be medium bodied. Fruity esters, chill haze, and diacetyl should not be perceived.')
,
( 'Vienna/Marzen/Oktoberfest','Vienna','Beers in this category are reddish brown or copper colored. They are medium in body. The beer is characterized by malty aroma and slight malt sweetness. The malt aroma and flavor may have a dominant toasted character. Hop bitterness is clean and crisp. Noble-type hop aromas and flavors should be low or mild. Fruity esters, diacetyl, and chill haze should not be perceived.')
,
( 'Vienna/Marzen/Oktoberfest','Marzen/Oktoberfest','Marzens are characterized by a medium body and broad range of color. Oktoberfests can range from golden to reddish brown. Sweet maltiness should dominate slightly over a clean, hop bitterness. Malt character should be toasted rather than strongly caramel (though a low level of light caramel character is acceptable) . Breadlike or biscuitlike malt character is acceptable in aroma and flavor. Hop aroma and flavor should be low but notable. Fruity esters should not be perceived. Diacetyl and chill haze should not be perceived.')
,
( 'German-Style Ale','Kolsch','Kolsch is warm fermented and aged at cold temperatures (German ale or alt-style beer) . Kolsch is characterized by a golden color and a slightly dry, subtly sweet and sometimes, but not always, wine-like (chardonnay-like) palate. Caramel character should not be evident. The body is light. This beer has low hop flavor and aroma with medium bitterness. Wheat can be used in brewing this beer that is fermented using ale yeast, though lager yeast is sometimes used in the bottle or final cold conditioning process. Fruity esters should be minimally perceived, if at all. Chill haze should be absent or minimal.')
,
( 'German-Style Ale','Dusseldorf-Style Altbier','Copper to brown in color, this German ale may be highly hopped (although the 25 to 35 IBU range is more normal for the majority of altbiers from Dusseldorf) and has a medium body and malty flavor. A variety of malts, including wheat, may be used. Hop character may be low to high in the flavor and aroma. The overall impression is clean, crisp, and flavorful. Fruity esters should be low. No diacetyl or chill haze should be perceived.')
,
( 'German-Style Wheat','Weizen/Weissbier','The aroma and flavor of a weissbier with yeast is decidedly fruity and phenolic. The phenolic characteristics are often described as clove- or nutmeglike and can be smoky or even vanillalike. Bananalike esters are often present. These beers are made with at least 50 percent malted wheat, and hop rates are quite low. Hop flavor and aroma are absent. Weissbier is well attenuated and very highly carbonated, yet its relatively high starting gravity and alcohol content make it a medium- to full-bodied beer. The color is very pale to a pale amber. Because yeast is present, the beer will have yeast flavor and a characteristically fuller mouthfeel. If this is served with yeast, the beer may be appropriately very cloudy. No diacetyl should be perceived.')
,
( 'German-Style Wheat','Berliner Weisse','This is very pale in color and the lightest of all the German wheat beers. The unique combination of a yeast and lactic acid bacteria fermentation yields a beer that is acidic, highly attenuated, and very light bodied. The carbonation of a Berliner weisse is high, and hop rates are very low. Hop character should not be perceived. Fruity esters will be evident. No diacetyl should be perceived.')
,
( 'German-Style Wheat','Dunkelweizen','This beer style is characterized by a distinct sweet maltiness and a chocolatelike character from roasted malt. Estery and phenolic elements of this weissbier still prevail. Color can range from copper-brown to dark brown. Dunkel weissbier is well attenuated and very highly carbonated, and hop bitterness is low. Hop flavor and aroma are absent. Usually dark barley malts are used in conjunction with dark cara or color malts, and the percentage of wheat malt is at least 50 percent. If this is served with yeast, the beer may be appropriately very cloudy. No diacetyl should be perceived.')
,
( 'German-Style Wheat','Weizenbock/Weissbock','This style can be either pale or dark (golden to dark brown in color) and has a high starting gravity and alcohol content. The malty sweetness of a weizenbock is balanced with a clovelike phenolic and fruity-estery banana element to produce a well-rounded aroma and flavor. As is true with all German wheat beers, hop bitterness is low and carbonation is high. Hop flavor and aroma are absent. It has a medium to full body. If dark, a mild roast malt character should emerge in flavor and to a lesser degree in the aroma. If this is served with yeast the beer may be appropriately very cloudy. No diacetyl should be perceived.')
,
( 'Smoked','Bamberg-Style Rauchbier','Rauchbier should have smoky characters prevalent in the aroma and flavor. The beer is generally toasted malty sweet and full bodied with low to medium hop bitterness. Noble-type hop flavor is low but perceptible. Low noble-type hop aroma is optional. The aroma should strike a balance between malt, hop, and smoke. Fruity esters, diacetyl, and chill haze should not be perceived.')
,
( 'Smoked','Classic-Style','Any classic style of beer can be smoked; the goal is to reach a balance between the style''s character and the smoky properties. Brewer should specify classic style.')
,
( 'Smoked','Other','Any beer to which smoke flavors have been added')
,
( 'Fruit & Vegatable','Fruit & Vegatable','Fruit and vegetable beers are any beers using fruit or fruit extracts or vegetables as an adjunct in either primary or secondary fermentation, providing obvious (ranging from subtle to intense) , yet harmonious, fruit qualities. Fruit or vegetable qualities should not be overpowered by hop character. If a fruit or vegetable (such as juniper berry or chili pepper) has an herbal or spice quality, it is more appropriate to consider it in the herb and spice beers category. Acidic bacterial fermentation characters would not be appropriate for this style.')
,
( 'Fruit & Vegatable','Classic','Any classic-style beer using fruits or vegetables as part of the flavor profile and providing obvious, yet harmonious, fruit or vegetable qualities. Brewer should specify classic style.')
,
( 'Herb & Spice','Herb & Spice','Herb beers use herbs or spices (derived from roots, seeds, fruits, vegetable, flowers, etc.) other than or in addition to hops to create a distinct (ranging from subtle to intense) character, though individual characters of herbs and/or spices used may not always be identifiable. Underhopping often, but not always, allows the spice or herb to contribute to the flavor profile.')
,
( 'Herb & Spice','Classic','Any classic-style beer using herbs or spices as part of the flavor profile and providing obvious, yet harmonious, herb and spice flavor. Brewer should specify classic style.')
,
( 'Specialty Beer','Specialty','These beers are brewed using unusual fermentables other than, or in addition to, malted barley. The distinctive characters of these special ingredients should be evident either in the aroma or flavor of the beer, but not necessarily in overpowering quantities. For example, honey, maple syrup or potatoes would be considered unusual. Rice, corn, or wheat are not considered unusual.')
,
( 'Specialty Beer','Classic','Any classic-style beer to which special ingredients have been added or a special process has been. Brewer should specify classic style.')
,
( 'Calif Common Beer','Calif Common','Light amber to copper. This beer has a medium body, toasted or caramellike maltiness in aroma and flavor, and medium to high hop bitterness. Hop flavor is medium to high. Aroma is medium, and fruitiness and esters are low. Low diacetyl is OK. Uses lager yeast. This beer is fermented at warm temperatures but aged at cold temperatures.')
,
( 'Mead/Traditional','Sparkling Traditional','Effervescent. Dry, medium or sweet. Light to medium body. No flavors other than honey. Honey character in aroma and flavor. Low to medium fruity acidity. Color depends on honey type.')
,
( 'Mead/Traditional','Still Melomel','Melomel is made with any fruit or vegetable except apples or grapes. Color should represent ingredients. Honey character apparent in aroma and flavor. Absence of harsh or stale character. Can be dry, medium or sweet, which must be designated on entry form. Not effervescent. Light to full body.')
,
( 'Mead/Traditional','Sparkling Braggot','Effervescent. Made with malt and honey. Dry, medium or sweet (designate on entry form). Light to medium body. Honey flavors predominate.')
,
( 'Mead/Traditional','Still Braggot','Not effervescent. Made with malt. Dry, medium or sweet (designate on entry form). Light to medium body. Honey flavors predominate.')


go


checkpoint
go