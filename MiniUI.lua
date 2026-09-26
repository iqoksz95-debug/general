return function(AetheriaUI, Window, SafeToggleWindow)

    local MiniUI = {
        Enabled = false,
        MainWindowVisible = not (Window and Window.Closed),
        UIS = game:GetService("UserInputService"),
        TS = game:GetService("TweenService"),
        Gui = Instance.new("ScreenGui", game:GetService("CoreGui")),
        Bg = Instance.new("Frame"),
        Corner = Instance.new("UICorner"),
        Stroke = Instance.new("UIStroke"),
        Icon = Instance.new("ImageLabel"),
        Title = Instance.new("TextLabel"),
        Btn = Instance.new("TextButton"),
        BtnCorner = Instance.new("UICorner"),
        Dragging = false,
        DragStart = nil,
        StartPos = nil,
        CurrentTween = nil,
        AnimToken = 0
    }

    MiniUI.Gui.Name = "AetheriaUIMini"

    MiniUI.Bg.Parent = MiniUI.Gui
    MiniUI.Bg.AnchorPoint = Vector2.new(0.5, 0)
    MiniUI.Bg.Position = UDim2.new(0.5, 0, 0, -60)
    MiniUI.Bg.Size = UDim2.new(0, 200, 0, 38)
    MiniUI.Bg.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    MiniUI.Bg.BackgroundTransparency = 0.2
    MiniUI.Bg.ClipsDescendants = true
    MiniUI.Bg.Visible = false

    MiniUI.Corner.CornerRadius = UDim.new(0, 8)
    MiniUI.Corner.Parent = MiniUI.Bg

    MiniUI.Stroke.Parent = MiniUI.Bg
    MiniUI.Stroke.Color = Color3.fromRGB(80, 80, 80)
    MiniUI.Stroke.Transparency = 0.4
    MiniUI.Stroke.Thickness = 1
    MiniUI.Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    MiniUI.Icon.Parent = MiniUI.Bg
    MiniUI.Icon.BackgroundTransparency = 1
    MiniUI.Icon.Position = UDim2.new(0, 10, 0.5, -8)
    MiniUI.Icon.Size = UDim2.new(0, 16, 0, 16)
    MiniUI.Icon.ImageColor3 = Color3.fromRGB(220, 220, 220)

    task.spawn(function()
        if AetheriaUI and type(AetheriaUI.GetIcon) == "function" then
            local iconData = AetheriaUI:GetIcon("door-open")
            if type(iconData) == "table" then
                MiniUI.Icon.Image = iconData.Image or ""
                MiniUI.Icon.ImageRectOffset = iconData.ImageRectOffset or Vector2.new()
                MiniUI.Icon.ImageRectSize = iconData.ImageRectSize or Vector2.new()
            elseif type(iconData) == "string" then
                MiniUI.Icon.Image = iconData
            end
        else
            MiniUI.Icon.Image = "rbxassetid://10723346959"
        end
    end)

    MiniUI.Title.Parent = MiniUI.Bg
    MiniUI.Title.BackgroundTransparency = 1
    MiniUI.Title.Position = UDim2.new(0, 32, 0, 0)
    MiniUI.Title.Size = UDim2.new(0, 70, 1, 0)
    MiniUI.Title.Text = "AetheriaUI"
    MiniUI.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniUI.Title.Font = Enum.Font.GothamBold
    MiniUI.Title.TextSize = 13
    MiniUI.Title.TextXAlignment = Enum.TextXAlignment.Left

    MiniUI.Btn.Parent = MiniUI.Bg
    MiniUI.Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    MiniUI.Btn.Position = UDim2.new(1, -78, 0.5, -11)
    MiniUI.Btn.Size = UDim2.new(0, 68, 0, 22)
    MiniUI.Btn.Text = "Expand"
    MiniUI.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniUI.Btn.Font = Enum.Font.GothamMedium
    MiniUI.Btn.TextSize = 11

    MiniUI.BtnCorner.CornerRadius = UDim.new(0, 6)
    MiniUI.BtnCorner.Parent = MiniUI.Btn

    do
        local TITLE_GAP = 10
        local textBounds = game:GetService("TextService"):GetTextSize(
            MiniUI.Title.Text, MiniUI.Title.TextSize, MiniUI.Title.Font, Vector2.new(1000, 20)
        )

        MiniUI.Title.Size = UDim2.new(0, textBounds.X, 1, 0)

        local btnX = 32 + textBounds.X + TITLE_GAP
        MiniUI.Btn.Position = UDim2.new(0, btnX, 0.5, -11)
        MiniUI.Bg.Size = UDim2.new(0, btnX + MiniUI.Btn.Size.X.Offset + 10, 0, 38)
    end

    MiniUI.BgInputConn = MiniUI.Bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            MiniUI.Dragging = true
            MiniUI.DragStart = input.Position
            MiniUI.StartPos = MiniUI.Bg.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    MiniUI.Dragging = false
                end
            end)
        end
    end)

    MiniUI.UISInputConn = MiniUI.UIS.InputChanged:Connect(function(input)
        if MiniUI.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - MiniUI.DragStart
            MiniUI.TS:Create(MiniUI.Bg, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(MiniUI.StartPos.X.Scale, MiniUI.StartPos.X.Offset + delta.X, MiniUI.StartPos.Y.Scale, MiniUI.StartPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    MiniUI.Animate = function(show)
        MiniUI.AnimToken = MiniUI.AnimToken + 1
        local currentToken = MiniUI.AnimToken

        if MiniUI.CurrentTween then
            MiniUI.CurrentTween:Cancel()
            MiniUI.CurrentTween = nil
        end

        if show then
            if not MiniUI.Enabled then return end
            MiniUI.Bg.Visible = true
        end

        local currentXScale, currentXOffset = MiniUI.Bg.Position.X.Scale, MiniUI.Bg.Position.X.Offset
        local targetY = show and 15 or -60

        MiniUI.CurrentTween = MiniUI.TS:Create(MiniUI.Bg, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(currentXScale, currentXOffset, 0, targetY)
        })

        MiniUI.CurrentTween.Completed:Connect(function()
            if currentToken == MiniUI.AnimToken then
                if not show then
                    MiniUI.Bg.Visible = false
                end
            end
        end)

        MiniUI.CurrentTween:Play()
    end

    MiniUI.SetToggle = function(state)
        MiniUI.Enabled = state
        local isMainClosed = (Window and Window.Closed == true) or (not MiniUI.MainWindowVisible)
        if state and isMainClosed then
            MiniUI.Animate(true)
        else
            MiniUI.Animate(false)
        end
    end

    MiniUI.BtnClickConn = MiniUI.Btn.MouseButton1Click:Connect(function()
        SafeToggleWindow()
    end)

    local function ApplyMiniUITheme()
        local themeName = AetheriaUI:GetCurrentTheme()
        local themeTable = themeName and AetheriaUI:GetThemes()[themeName]
        if not themeTable then return end

        MiniUI.Bg.BackgroundColor3 = Color3.fromHex(themeTable.Background or "#161616")
        MiniUI.Stroke.Color = Color3.fromHex(themeTable.Outline or "#505050")
        MiniUI.Icon.ImageColor3 = Color3.fromHex(themeTable.Icon or "#dcdcdc")
        MiniUI.Title.TextColor3 = Color3.fromHex(themeTable.Text or "#ffffff")
        MiniUI.Btn.BackgroundColor3 = Color3.fromHex(themeTable.Accent or "#202020")
        MiniUI.Btn.TextColor3 = Color3.fromHex(themeTable.Text or "#ffffff")
    end

    ApplyMiniUITheme()

    return MiniUI, ApplyMiniUITheme
end
