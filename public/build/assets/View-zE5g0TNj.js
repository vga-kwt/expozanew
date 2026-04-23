import{j as t,L as e}from"./app-CBPioDtJ.js";/* empty css            */function s({page:i}){return t.jsxs(t.Fragment,{children:[t.jsx(e,{title:i.meta_title||i.title_en}),t.jsxs("div",{className:"bg-background min-h-svh flex flex-col",children:[t.jsxs("header",{className:"flex flex-col items-center gap-4 px-4 pt-10 text-center",children:[t.jsx("div",{className:"mb-1 flex h-10 w-10 items-center justify-center rounded-md",children:t.jsx("img",{src:`${window.location.origin}/Group.svg`,alt:"logo"})}),t.jsxs("div",{className:"space-y-1",children:[t.jsx("h1",{className:"text-2xl font-semibold",children:i.title_en}),i.meta_description&&t.jsx("p",{className:"text-muted-foreground text-sm max-w-2xl mx-auto",children:i.meta_description})]})]}),t.jsx("main",{className:"flex-1 px-4 pb-16 pt-8 md:px-12 lg:px-24",children:t.jsxs("div",{className:"w-full space-y-8",children:[t.jsxs("div",{className:"grid grid-cols-1 gap-4 border-b pb-4 md:grid-cols-2",children:[t.jsx("div",{children:t.jsx("h2",{className:"text-xl font-bold",children:i.title_en})}),i.title_ar&&t.jsx("div",{className:"text-right",dir:"rtl",style:{fontFamily:'"Noto Sans Arabic", "Segoe UI", Tahoma, Arial, sans-serif',direction:"rtl",textAlign:"right",unicodeBidi:"embed"},children:t.jsx("h2",{className:"text-xl font-bold",style:{direction:"rtl",textAlign:"right"},children:i.title_ar})})]}),t.jsxs("div",{className:"grid grid-cols-1 gap-8 md:grid-cols-2",children:[t.jsx("div",{className:"prose prose-base max-w-none dark:prose-invert prose-headings:font-bold prose-p:text-justify prose-p:leading-relaxed",children:t.jsx("div",{className:"space-y-4",dangerouslySetInnerHTML:{__html:i.content_en||""}})}),i.content_ar&&t.jsxs("div",{className:"max-w-none",dir:"rtl",style:{fontFamily:'"Noto Sans Arabic", "Segoe UI", Tahoma, Arial, sans-serif',direction:"rtl",textAlign:"right"},children:[t.jsx("style",{children:`
                                        [dir="rtl"] p {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            margin-bottom: 1rem;
                                            line-height: 1.75;
                                        }
                                        [dir="rtl"] h1, [dir="rtl"] h2, [dir="rtl"] h3, [dir="rtl"] h4, [dir="rtl"] h5, [dir="rtl"] h6 {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            font-weight: bold;
                                            margin-bottom: 1rem;
                                        }
                                        [dir="rtl"] ul, [dir="rtl"] ol {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            padding-right: 1.5rem;
                                            padding-left: 0;
                                            margin-right: 0;
                                        }
                                        [dir="rtl"] li {
                                            text-align: right !important;
                                            direction: rtl !important;
                                            margin-bottom: 0.5rem;
                                        }
                                        [dir="rtl"] div {
                                            direction: rtl !important;
                                            text-align: right !important;
                                        }
                                    `}),t.jsx("div",{className:"space-y-4",style:{direction:"rtl",textAlign:"right",lineHeight:"1.75",fontSize:"1rem"},dangerouslySetInnerHTML:{__html:i.content_ar}})]})]})]})})]})]})}export{s as default};
