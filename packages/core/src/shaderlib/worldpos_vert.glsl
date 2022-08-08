#ifdef O3_NEED_WORLDPOS
    vec4 temp_pos = u_modelMat * position;
    vec4  temp_viewPos = u_viewMat * temp_pos;
    v_pos = temp_pos.xyz / temp_pos.w;
    v_viewPos = temp_viewPos.xyz / temp_viewPos.w;

#endif
