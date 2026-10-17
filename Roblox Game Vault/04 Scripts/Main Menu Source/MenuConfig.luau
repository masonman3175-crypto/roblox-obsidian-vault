local C = {}
C.Title = 'O BLAH WARFARE'
C.SkinOrder = {'STREET', 'NIGHT', 'DUNE', 'GLACIER'}
C.Skins = {
    STREET = {Name='Street Pilot', Tag='THE ORIGINAL', Hands=Color3.fromRGB(217,171,122), Torso=Color3.fromRGB(166,47,40), Arms=Color3.fromRGB(166,47,40), Legs=Color3.fromRGB(53,72,99), Accent=Color3.fromRGB(235,214,174), Cap=Color3.fromRGB(199,47,39)},
    NIGHT = {Name='Night Shift', Tag='URBAN / STEALTH', Hands=Color3.fromRGB(181,131,91), Torso=Color3.fromRGB(30,39,53), Arms=Color3.fromRGB(40,49,65), Legs=Color3.fromRGB(22,29,40), Accent=Color3.fromRGB(98,170,194), Cap=Color3.fromRGB(22,28,39)},
    DUNE = {Name='Dune Runner', Tag='DUST / UTILITY', Hands=Color3.fromRGB(217,171,122), Torso=Color3.fromRGB(181,155,112), Arms=Color3.fromRGB(191,169,132), Legs=Color3.fromRGB(94,84,66), Accent=Color3.fromRGB(233,201,137), Cap=Color3.fromRGB(94,84,66)},
    GLACIER = {Name='Whiteout', Tag='COLD / CLEAN', Hands=Color3.fromRGB(202,155,114), Torso=Color3.fromRGB(205,220,228), Arms=Color3.fromRGB(185,205,218), Legs=Color3.fromRGB(52,75,94), Accent=Color3.fromRGB(87,196,216), Cap=Color3.fromRGB(41,59,76)},
}
C.WrapOrder = {'ORIGINAL','CARBON','EMBER','COBALT','JADE','ARCTIC'}
C.Wraps = {
    ORIGINAL={Name='Original', Tag='FACTORY FINISH', Swatch=Color3.fromRGB(208,132,53)},
    CARBON={Name='Carbon', Tag='MATTE / CHARCOAL', Primary=Color3.fromRGB(37,42,49), Secondary=Color3.fromRGB(23,27,33), Accent=Color3.fromRGB(137,149,158), Swatch=Color3.fromRGB(48,56,66)},
    EMBER={Name='Ember', Tag='BURNT RED / BLACK', Primary=Color3.fromRGB(157,49,33), Secondary=Color3.fromRGB(30,31,35), Accent=Color3.fromRGB(226,142,58), Swatch=Color3.fromRGB(192,65,41)},
    COBALT={Name='Cobalt', Tag='DEEP BLUE / STEEL', Primary=Color3.fromRGB(39,90,159), Secondary=Color3.fromRGB(29,40,57), Accent=Color3.fromRGB(124,185,225), Swatch=Color3.fromRGB(57,123,205)},
    JADE={Name='Jade', Tag='FIELD GREEN / GOLD', Primary=Color3.fromRGB(38,116,94), Secondary=Color3.fromRGB(26,45,40), Accent=Color3.fromRGB(207,173,91), Swatch=Color3.fromRGB(53,155,121)},
    ARCTIC={Name='Arctic', Tag='ICE WHITE / GRAPHITE', Primary=Color3.fromRGB(206,223,232), Secondary=Color3.fromRGB(48,64,79), Accent=Color3.fromRGB(102,199,219), Swatch=Color3.fromRGB(216,235,244)},
}
C.DefaultSkin, C.DefaultWrap, C.DefaultWeapon = 'STREET', 'ORIGINAL', 'W1'
return C
