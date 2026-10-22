from pathlib import Path
import re, sys

ROOT = Path(__file__).parent
mode = sys.argv[1] if len(sys.argv)>1 else 'modified'
base = ROOT/'baseline'/'src'
tree = (ROOT/'modified'/'src' if mode=='modified' else base) if mode!='rollback' else Path(sys.argv[2])
def read(name): return (tree/name).read_text(encoding='utf-8')
m=read('Monetization.luau')
passes=m.split('Monetization.Passes = {',1)[1].split('Monetization.PassOrder',1)[0]
products=m.split('Monetization.Products = {',1)[1].split('Monetization.ProductOrder',1)[0]
pass_count=len(re.findall(r'^\s*\w+ = \{Id = ',passes,re.M))
product_count=len(re.findall(r'^\s*\w+ = \{Id = ',products,re.M))
assert pass_count==13
if mode=='baseline' or mode=='rollback':
    assert product_count==13 and 'UltraEgg' not in products
    assert 'StudioPurchase' in read('Purchase.luau')
    assert 'onStudioPurchase' in read('MonetizationService.luau')
    print('BASELINE PASS: 13 passes, 13 products, free StudioPurchase present, Ultra absent')
else:
    assert product_count==14
    prices=[int(n) for n in re.findall(r'\bPrice = (\d+)',passes+products)]
    assert len(prices)==27 and max(prices)==99 and min(prices)>=1
    for key, product_id in {'StrengthSmall':3719745475,'StrengthMedium':3719749527,'StrengthLarge':3719749718,'CoinsSmall':3719749809}.items():
        assert f'{key} = {{Id = {product_id},' in products
    assert 'StudioPurchase' not in read('Purchase.luau')
    assert 'onStudioPurchase' not in read('MonetizationService.luau')
    assert 'if egg.ProductKey and not free' in read('EggService.luau')
    assert 'UltraEgg = "Ultra"' in read('ShopController.luau')
    assert 'ULTRA' in read('UiStyle.luau')
    assert 'return EggService.Hatch(player, "Ultra", 1, false, true)' in read('MonetizationService.luau')
    assert 'granted == false' in read('MonetizationService.luau')
    e=read('Eggs.luau')
    for egg in ['Mega','Ultra']:
        block=e.split(egg+' = {',1)[1].split('}},',1)[0]
        odds=[int(x) for x in re.findall(r'Chance = (\d+)',block)]
        assert sum(odds)==100,(egg,odds)
    print('MODIFIED PASS: 13 passes, 14 products, max R$99, paid egg odds 100%, StudioPurchase removed')
