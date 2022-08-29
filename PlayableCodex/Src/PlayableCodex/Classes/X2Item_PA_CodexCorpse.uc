class X2Item_PA_CodexCorpse extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Resources;
    Resources.AddItem(Create_Tech_CorpseCyberus());

    return Resources;
}

static function X2DataTemplate Create_Tech_CorpseCyberus()
{
	local X2ItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, 'Tech_CorpseCyberus');

	Template.strImage = "img:///UILibrary_StrategyImages.X2InventoryIcons.Inv_Codex_Brain";
	Template.ItemCat = 'resource';
	Template.MaxQuantity = 6;
	Template.LeavesExplosiveRemains = true;
	Template.bAlwaysRecovered = true;

	return Template;
}