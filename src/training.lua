


function train(model, learning_rate, epochs)
    local nn = model

    for i = 1, epochs do
        nn:backpropagation(learning_rate)
    end

    return nn
end




--train(criar_rede_neural({2, 4, 4, 3}), 0.01, 1000)