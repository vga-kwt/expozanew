import React, { forwardRef, useImperativeHandle, useRef } from 'react';
import ReactQuill, { ReactQuillProps } from 'react-quill';
import 'react-quill/dist/quill.snow.css';

// Wrapper component to suppress findDOMNode warning
const ReactQuillWrapper = forwardRef<ReactQuill, ReactQuillProps>((props, ref) => {
    const quillRef = useRef<ReactQuill>(null);

    useImperativeHandle(ref, () => quillRef.current as ReactQuill);

    return <ReactQuill ref={quillRef} {...props} />;
});

ReactQuillWrapper.displayName = 'ReactQuillWrapper';

export default ReactQuillWrapper;

