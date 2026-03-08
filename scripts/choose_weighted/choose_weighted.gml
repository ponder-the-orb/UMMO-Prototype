function choose_weighted(_options, _weights) {
    var _total_weight = 0;
    for (var i = 0; i < array_length(_weights); i++) _total_weight += _weights[i];
    
    var _roll = irandom(_total_weight - 1);
    var _cursor = 0;
    
    for (var i = 0; i < array_length(_options); i++) {
        _cursor += _weights[i];
        if (_roll < _cursor) return _options[i];
    }
}