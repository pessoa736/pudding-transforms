


function train(args)
    local nn = args["model"] 
    local epochs = args["epochs"] or 100

    for i = 1, epochs do
        nn:think(args)
        nn:backpropagation(args)
    end

    return nn
end




if TRAINIGTEST then
    local config = {
        model = criar_rede_neural({2, 3, 5}),
        epochs = 100000,
        learning_rate = 0.0001,
    }

    config.model = train(config)
    config.model:save("test_training")
    print("Model trained and saved as 'test_training'")

end

