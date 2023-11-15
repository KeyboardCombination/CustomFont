local CustomFont = {}
CustomFont.__index = CustomFont

local chars = {
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"60",
	"1A",
	"1A",
	"00",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"1A",
	"07",
	"08",
	"09",
	"10",
	"10",
	"16",
	"13",
	"05",
	"09",
	"09",
	"0D",
	"10",
	"07",
	"07",
	"07",
	"0B",
	"10",
	"10",
	"10",
	"10",
	"10",
	"10",
	"10",
	"10",
	"10",
	"10",
	"07",
	"07",
	"0D",
	"10",
	"0D",
	"0D",
	"16",
	"14",
	"11",
	"11",
	"14",
	"10",
	"0F",
	"14",
	"14",
	"08",
	"0C",
	"11",
	"0E",
	"17",
	"14",
	"16",
	"0F",
	"16",
	"10",
	"0D",
	"0F",
	"14",
	"12",
	"1B",
	"11",
	"0F",
	"10",
	"09",
	"0B",
	"09",
	"0D",
	"0D",
	"0D",
	"0F",
	"10",
	"0D",
	"10",
	"0F",
	"09",
	"10",
	"11",
	"07",
	"07",
	"0E",
	"07",
	"17",
	"11",
	"10",
	"10",
	"10",
	"0A",
	"0B",
	"0A",
	"10",
	"0E",
	"17",
	"0E",
	"0E",
	"0D",
	"0B",
	"0D",
	"0B",
	"11",
	"1A"
}

local OutlineOffsets = {
	UDim2.new(0, -1, 0, -1),
	UDim2.new(0, 1, 0, 1),
	UDim2.new(0, 1, 0, -1),
	UDim2.new(0, -1, 0, 1),
}

local function calculateNumber(currentCharacter: string): (number, number)
	local subbed = currentCharacter:byte() % 128
	local char = utf8.char(subbed)
	local xNum = tonumber(chars[char:byte()], 16)
	local fnt = (32 - xNum) / 2
	local num = subbed * 32
	local xValue = (num % 512) + fnt
	local yValue = (math.floor(num / 512) * 32)

	return xValue, yValue
end

function CustomFont.redraw(theString, multiplier, textLabel, textStrokeTransarency)
	local Frame = textLabel:FindFirstChild("TextContent");
	if(not Frame)then
		return;
	end
	
	Frame:SetAttribute("CustomFont", true);

	-- inorder hopefully??
	textStrokeTransarency = textLabel:GetAttribute("TextStrokeTransparency") or textStrokeTransarency;
	textLabel:SetAttribute("TextStrokeTransparency", textStrokeTransarency);
	
	local previousSize = 0;
	for i = 1, #theString do
		-- u stupid liberal why do u do thius
		local byte = theString:byte(i,i);
		local xNum = tonumber(chars[byte]or chars[1], 16);
		
		local xScale = xNum / 32
		local container = Frame:FindFirstChild(i)
		
		if (not container) then
			continue
		end
		
		container.Size = UDim2.new(0, xScale * multiplier, 0, 1 * multiplier)
		container.BackgroundTransparency = 1;
		container.Position = UDim2.new(0, previousSize, 0, 0);
		container.ZIndex = textLabel.ZIndex + 1;
		container.ImageLabel.ImageColor3 = textLabel.TextColor3;

		previousSize = previousSize + (xScale * multiplier)
		for i, outline in container:GetChildren()do
			if(outline.Name ~= "Outline")then
				continue;
			end
			
			outline.ImageColor3 = textLabel.TextStrokeColor3;
			outline.ImageTransparency = textStrokeTransarency;
			outline.Position = OutlineOffsets[i];
		end
	end
	

	local SmallestXY = 0
	local BiggestX = previousSize
	local BiggestY = multiplier
	Frame.Size = UDim2.new(0, BiggestX, 0, BiggestY)

	local AnchorX = 0
	local AnchorY = 0
	local SizeX = 0
	local SizeY = 0

	if textLabel.TextXAlignment == Enum.TextXAlignment.Center then
		AnchorX = 0.5
		SizeX = 0.5
	elseif textLabel.TextXAlignment == Enum.TextXAlignment.Right then
		AnchorX = 1
		SizeX = 1
	end	

	if textLabel.TextYAlignment == Enum.TextYAlignment.Center then
		AnchorY = 0.5
		SizeY = 0.5
	elseif textLabel.TextYAlignment == Enum.TextYAlignment.Bottom then
		AnchorY = 1
		SizeY = 1
	end	

	Frame.Position = UDim2.new(SizeX, 0, SizeY, 0)
	Frame.AnchorPoint = Vector2.new(AnchorX, AnchorY)	
end

function CustomFont.draw(theString: string, multiplier: number, textLabel, textStrokeTransparency)
	if (not textLabel) then
		return
	end
	
	local Frame = textLabel:FindFirstChild("TextContent");
	if Frame then
		Frame:Destroy()
	end

	local Frame = Instance.new("Frame", textLabel)
	Frame.Name = "TextContent";
	Frame.BackgroundTransparency = 1
	Frame:SetAttribute("CustomFont", true)

	textLabel.TextTransparency = 1
	--textLabel.TextStrokeTransparency = 0

	local PreviousSize = 0
	for CharOffset, Character in utf8.codes(theString) do
		Character = utf8.char(Character)

		if not chars[Character:byte()] then
			Character = utf8.char(1)
		end

		local container = Instance.new("Frame");
		local xNum = tonumber(chars[Character:byte()], 16)
		local xScale = xNum / 32

		container.Size = UDim2.new(0, xScale * multiplier, 0, 1 * multiplier)
		container.BackgroundTransparency = 1;
		container.Position = UDim2.new(0, PreviousSize, 0, 0)
		container.ZIndex = textLabel.ZIndex + 1
		container.Parent = Frame
		container.Name = CharOffset;

		local Image = Instance.new("ImageLabel")
		Image.Image = "rbxassetid://11363842965"
		Image.ImageRectSize = Vector2.new(xNum, 32)
		Image.BackgroundTransparency = 1
		Image.ImageColor3 = textLabel.TextColor3
		Image.ZIndex = container.ZIndex
		Image.Size = UDim2.new(1,0,1,0);
		Image.ImageRectOffset = Vector2.new(calculateNumber(Character))
		PreviousSize = PreviousSize + (xScale * multiplier)

		--if (textStrokeTransparency < 1) or (textLabel:GetAttribute("TextStrokeTransparency") and textLabel:GetAttribute("TextStrokeTransparency") < 1) then			
			local FinalTextStroke = textLabel:GetAttribute("TextStrokeTransparency") or textStrokeTransparency
			textLabel:SetAttribute("TextStrokeTransparency", FinalTextStroke)

			for i = 1, 4 do
				local Outline = Image:Clone()
				Outline.Name = "Outline";
				Outline.ZIndex = Image.ZIndex - 1
				Outline.ImageColor3 = textLabel.TextStrokeColor3
				Outline.ImageTransparency = FinalTextStroke
				Outline.Position = OutlineOffsets[i]

				Outline.Parent = container
			end

			--if not textLabel:SetAttribute("TextStrokeTransparency") then
			--	textLabel:SetAttribute("TextStrokeTransparency", FinalTextStroke)
			--end
		--end

		Image.Parent = container;
	end

	textLabel.TextStrokeTransparency = 1

	local SmallestXY = 0
	local BiggestX = PreviousSize
	local BiggestY = multiplier

	Frame.Size = UDim2.new(0, BiggestX, 0, BiggestY)

	local AnchorX = 0
	local AnchorY = 0
	local SizeX = 0
	local SizeY = 0

	if textLabel.TextXAlignment == Enum.TextXAlignment.Center then
		AnchorX = 0.5
		SizeX = 0.5
	elseif textLabel.TextXAlignment == Enum.TextXAlignment.Right then
		AnchorX = 1
		SizeX = 1
	end	

	if textLabel.TextYAlignment == Enum.TextYAlignment.Center then
		AnchorY = 0.5
		SizeY = 0.5
	elseif textLabel.TextYAlignment == Enum.TextYAlignment.Bottom then
		AnchorY = 1
		SizeY = 1
	end	

	Frame.Position = UDim2.new(SizeX, 0, SizeY, 0)
	Frame.AnchorPoint = Vector2.new(AnchorX, AnchorY)
end

function CustomFont.displayString(theString: string, multiplier: number, textLabel, textStrokeTransparency): ()
	if(textLabel:GetAttribute("displayString") == theString)then
		return CustomFont.redraw(
			theString,
			multiplier,
			textLabel,
			textStrokeTransparency
		);
	else
		textLabel:SetAttribute("displayString", theString);
		return CustomFont.draw(
			theString,
			multiplier,
			textLabel,
			textStrokeTransparency
		);
	end
end

return CustomFont